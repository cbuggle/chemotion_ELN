# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_process_actions
#
#  id                       :uuid             not null, primary key
#  reaction_process_step_id :uuid
#  action_name              :string
#  position                 :integer
#  workup                   :json
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ReactionProcessAction < ApplicationRecord
  belongs_to :reaction_process_step

  validate :validate_workup

  delegate :reaction, :reaction_process, to: :reaction_process_step

  def is_condition?
    %w[CONDITION].include?(action_name)
  end

  def update_by_params(action_params)
    ActiveRecord::Base.transaction do
      update(action_params)
      update_duration_by_workup(action_params.workup)
      save_intermediate(action_params.workup) if action_name == 'SAVE'
    end
  end

  def save_intermediate(workup)
    sample = Sample.find_by(id: workup.sample_id) || Sample.new(decoupled: true, creator: reaction.creator,
                                                                molecule: Molecule.find_or_create_dummy)

    sample.collections << (reaction.collections - sample.collections)

    sample.hide_in_eln = workup['hide_in_eln']

    sample.name = workup['sample']['name'] || "#{workup['sample']['intermediate_type']} #{sample.short_label}"
    sample.short_label = workup['sample']['short_label']
    sample.external_label = sample.short_label
    sample.description = workup['sample']['description']
    sample.target_amount_value = workup['sample']['target_amount_value'].to_f
    sample.target_amount_unit = workup['sample']['target_amount_unit']
    sample.purity = workup['sample']['purity'].to_f
    sample.location = workup['sample']['location']

    sample.save!

    self.workup['sample_id'] = sample.id
    save!

    ris = ReactionsIntermediateSample.find_or_create_by(reaction: reaction,
                                                        sample: sample,
                                                        reaction_step: reaction_process_step.step_number)
    ris.update(intermediate_type: workup['sample']['intermediate_type'])
  end

  def validate_workup
    validate_workup_sample if %w[ADD SAVE].include?(action_name)
  end

  def validate_workup_sample
    errors.add(:workup, 'Missing Sample') if workup['sample_id'].blank?
  end

  def medium
    return unless has_medium?

    Medium::Medium.find_by(id: workup['sample_id'])
  end

  def sample
    return unless has_sample?

    Sample.find_by(id: workup['sample_id'])
  end

  def has_sample?
    acts_as_sample? && workup['sample_id'].present?
  end

  def has_medium?
    acts_as_medium? && workup['sample_id'].present?
  end

  def acts_as_sample?
    !acts_as_medium?
  end

  def acts_as_medium?
    # These are the 3 subclasses stored in the STI table `media`
    %w[ADDITIVE MEDIUM DIVERSE_SOLVENT].include?(workup['acts_as'])
  end

  def update_position(position)
    actions = reaction_process_step.reaction_process_actions.order(:position).to_a
    actions.delete(self)
    actions.insert(position, self)
    actions.each_with_index { |action, idx| action.update(position: idx) }
    actions
  end

  def delete_from_reaction_process_step
    actions = reaction_process_step.reaction_process_actions.order(:position).to_a
    actions.delete(self)
    actions.each_with_index { |action, idx| action.update(position: idx) }

    destroy

    actions
  end
end
