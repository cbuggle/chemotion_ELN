# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_process_steps
#
#  id                           :uuid             not null, primary key
#  reaction_process_id        :uuid
#  reaction_process_vessel_id :uuid
#  name                         :string
#  vessel_preparations          :string
#  position                     :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  locked                       :boolean
#  duration                     :integer
#  start_time                   :integer
#

class ReactionProcessStep < ApplicationRecord
  belongs_to :reaction_process

  belongs_to :reaction_process_vessel, optional: true

  has_one :vessel, through: :reaction_process_vessel

  has_many :reaction_process_actions, dependent: :destroy

  delegate :reaction, to: :reaction_process

  def label
    "Step #{step_number}"
  end

  def step_number
    position + 1
  end

  def set_vessel(new_vessel)
    self.reaction_process_vessel = ReactionProcessVessel.find_by(
      reaction_process: reaction_process, vessel: new_vessel,
    )
    save
  end

  def append_action(action_params)
    action = reaction_process_actions.new(
      position: reaction_process_actions.count,
      start_time: duration,
    )

    action.parse_params action_params

    action.set_initial_description
    action.save
    action
  end

  def normalize_timestamps
    self.duration = reaction_process_actions.order(:position).reduce(0) do |sum, action|
      action.update(start_time: sum)
      sum + action.duration.to_i
    end
    save
    reaction_process.normalize_timestamps
  end

  def add_transfer_target_action(process_step, workup)
    new_action = ReactionProcessAction.new(action_name: 'TRANSFER', reaction_process_step: self, workup: workup)

    sample = Sample.find_by(id: workup['sample_id'])

    new_action.position = reaction_process_actions.count
    new_action.workup['description'] = "from #{process_step.label}:"
    new_action.workup['description'] += " #{sample.preferred_label || sample.short_label}"
    new_action.workup['description'] += " #{workup['transfer_percentage']}%"
    reaction_process_actions << new_action
    new_action
  end

  def toggle_locked
    self.locked = !locked
    save
  end

  def destroy_from_reaction_process
    steps = reaction_process.reaction_process_steps.order(:position).to_a
    steps.delete(self)
    steps.each_with_index { |step, idx| step.update(position: idx) }
    destroy

    reaction_process.normalize_timestamps
    steps
  end

  def added_materials(material_type)
    added_material_ids = reaction_process.reaction_process_steps.where('position <= ?', position).map do |process_step|
      process_step.added_material_ids(material_type)
    end.flatten.uniq

    case material_type
    when 'SOLVENT'
      Sample.find added_material_ids
    when 'ADDITIVE'
      Medium::Additive.find added_material_ids
    when 'MEDIUM'
      Medium::MediumSample.find added_material_ids
    when 'DIVERSE_SOLVENT'
      Medium::DiverseSolvent.find added_material_ids
    else
      []
    end
  end

  def added_material_ids(material_type)
    add_actions_acting_as(material_type).map { |action| action.workup['sample_id'] }
  end

  private

  def add_actions_acting_as(material_type)
    add_actions.select { |action| action.workup['acts_as'] == material_type }
  end

  def add_actions
    reaction_process_actions.select { |action| action.action_name == 'ADD' }
  end
end
