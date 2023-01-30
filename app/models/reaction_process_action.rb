# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_process_actions
#
#  id                         :uuid             not null, primary key
#  reaction_process_step_id :uuid
#  action_name                :string
#  position                   :integer
#  workup                     :json
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  starts_at                  :datetime
#  ends_at                    :datetime
#  duration                   :integer
#  start_time                 :integer
#

class ReactionProcessAction < ApplicationRecord
  belongs_to :reaction_process_step
  before_destroy :destroy_condition_end

  validate :validate_workup

  delegate :reaction, :reaction_process, to: :reaction_process_step

  def label
    "#{action_number} #{action_name} #{workup['description']}".titlecase
  end

  def action_number
    if is_condition?
      ''
    else
      reaction_process_step.numbered_actions.find_index(self) + 1
    end # this will be filtered for actions only (without condition actions)
  end

  def is_condition?
    %w[CONDITION CONDITION_END].include?(action_name)
  end

  def step_actions_count
    reaction_process_step.actions_count
  end

  def parse_params(action_params)
    update(action_params)
    update_duration_by_workup(action_params.workup)
    save_intermediate(action_params.workup) if action_name == 'SAVE'
  end

  def save_intermediate(workup)
    sample = Sample.find_by(id: workup.sample_id) || Sample.new(decoupled: true, creator: reaction.creator,
                                                                molecule: Molecule.find_or_create_dummy)

    sample.collections << (reaction.collections - sample.collections)

    sample.hide_in_eln = workup['hide_in_eln']
    sample.target_amount_value = workup['sample']['target_amount_value'].to_f
    sample.target_amount_unit = workup['sample']['target_amount_unit']
    sample.purity = workup['sample']['purity'].to_f
    sample.description = workup['sample']['description']
    sample.external_label = workup['sample']['external_label']
    sample.location = workup['sample']['location']
    sample.save!

    sample.external_label = sample.short_label unless sample.external_label.present?
    sample.name = "#{workup['sample']['intermediate_type']} #{sample.short_label}" if sample.name.blank?
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
    validate_workup_equip if %w[EQUIP].include?(action_name)
  end

  def validate_workup_equip
    errors.add(:workup, 'Missing Equipment') if workup['equipment'].blank?
  end

  def validate_workup_sample
    errors.add(:workup, 'Missing Sample') if workup['sample_id'].blank?
  end

  def set_initial_description
    return if workup['description'].present?

    case action_name
    when 'ADD'
      acts_as = workup['acts_as'] == 'DIVERSE_SOLVENT' ? 'SOLVENT' : workup['acts_as']
      workup['description'] = acts_as
      workup['description'] += " #{workup['target_amount_value']}"
      workup['description'] += " #{workup['target_amount_unit']}"

      sample_text = if has_medium?
                      Medium::Medium.find_by(id: workup['sample_id']).label
                    else
                      sample = Sample.find_by(id: workup['sample_id'])
                      sample.preferred_label || sample.short_label
                    end

      workup['description'] += " #{sample_text}"
    when 'SAVE'
      sample = Sample.find_by(id: workup['sample_id'])

      workup['description'] = workup['intermediate_type'].to_s
      workup['description'] += " #{sample.preferred_label || sample.short_label}"
      workup['description'] += " #{workup['target_amount_value']}"
      workup['description'] += " #{workup['target_amount_unit']}"
    when 'TRANSFER'
      transfer_step = ReactionProcessStep.find workup['transfer_target_step_id']
      sample = Sample.find_by(id: workup['sample_id'])

      workup['description'] = "to #{transfer_step.label}:"
      workup['description'] += " #{sample.preferred_label || sample.short_label}"
      workup['description'] += " #{workup['transfer_percentage']}%"
    when 'EQUIP'
      workup['description'] = " #{workup['mount_action']}"
      workup['description'] += " #{workup['equipment']}"
    when 'MOTION'
      workup['description'] = workup['motion_type'].to_s
      workup['description'] += " #{workup['motion_mode']}"
      workup['description'] += " #{workup['motion_speed']}"
      workup['description'] += " #{workup['motion_unit']}"
    when 'CONDITION'
      workup['description'] = workup['condition_tendency'].to_s
      workup['description'] += " #{workup['condition_type']}"
      workup['description'] += " #{workup['condition_value']}"
      workup['description'] += " #{workup['condition_unit']}"

    when 'REMOVE'
      workup['description'] += medium.label
      case workup['acts_as']
      when 'ADDITIVE'
        workup['description'] += " #{workup['remove_temperature']} °C"
        workup['description'] += " #{workup['remove_pressure']} mbar"

      when 'MEDIUM'
        workup['description'] += " #{workup['remove_repetitions']} times"
        workup['description'] += " #{workup['duration_in_minutes']} minutes"
      end
    when 'PURIFY'
      workup['description'] = workup['purify_type'].to_s
      workup['description'] += " #{workup['purify_automation']}"
    end
    workup['description'].squish!
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
    !has_medium?
  end

  def has_medium?
    %w[ADDITIVE MEDIUM DIVERSE_SOLVENT].include?(workup['acts_as'])
  end

  def update_position(position)
    actions = reaction_process_step.reaction_process_actions.order(:position).to_a
    actions.delete(self)
    actions.insert(position, self)
    actions.each_with_index { |action, idx| action.update(position: idx) }
    reaction_process_step.normalize_timestamps
    actions
  end

  def update_timer(timer_params)
    update(starts_at: timer_params[:starts_at])
    update(ends_at: timer_params[:ends_at])
    update(duration: timer_params[:duration])
    reaction_process_step.normalize_timestamps
  end

  def update_duration_by_workup(workup)
    update(duration: workup['duration_in_minutes'] * 60) if workup['duration_in_minutes']
    update(duration: workup['duration']) if workup['duration']
    reaction_process_step.normalize_timestamps
  end

  def delete_from_reaction_process_step
    actions = reaction_process_step.reaction_process_actions.order(:position).to_a
    actions.delete(self)
    actions.each_with_index { |action, idx| action.update(position: idx) }

    destroy

    reaction_process_step.normalize_timestamps
    actions
  end

  private

  def destroy_condition_end
    return unless action_name == 'CONDITION'

    condition_end = ReactionProcessAction.find_by(id: workup['condition_end_id'])&.destroy
  end
end
