# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_process_steps
#
#  id                         :uuid             not null, primary key
#  reaction_process_id        :uuid
#  name                       :string
#  position                   :integer
#  locked                     :boolean
#  duration                   :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  reaction_process_vessel_id :uuid
#
module ReactionProcessEditor
  class ReactionProcessStep < ApplicationRecord
    belongs_to :reaction_process

    # belongs_to :reaction_process_vessel, optional: true

    # has_one :vessel, through: :reaction_process_vessel

    has_many :reaction_process_actions, dependent: :destroy

    delegate :reaction, to: :reaction_process

    def label
      "#{step_number}/#{reaction_process.reaction_process_steps.count} #{name}"
    end

    def step_number
      position + 1
    end

    def numbered_actions
      @numbered_actions ||= reaction_process_actions.order(:position).reject(&:is_condition?)
    end

    def numbered_conditions
      @numbered_conditions ||= reaction_process_actions.order(:position).select(&:is_condition?)
    end

    # We assemble an Array of action_pre_conditions which the ReactionActionEntity indexes by its position.
    def action_pre_conditions
      @action_pre_conditions ||= [initial_conditions] + calculate_action_post_conditions
    end

    def final_conditions
      @final_conditions ||= action_pre_conditions.last
    end

    def action_count
      @action_count ||= reaction_process_actions.size
    end

    def last_action_position
      action_count - 1
    end

    def update_position(position)
      reaction_process_steps = reaction_process.reaction_process_steps.order(:position).to_a
      reaction_process_steps.delete(self)
      reaction_process_steps.insert(position, self)
      reaction_process_steps.each_with_index do |reaction_process_step, idx|
        reaction_process_step.update(position: idx)
      end
      reaction_process_steps
    end

    # def set_vessel(new_vessel)
    #   self.reaction_process_vessel = ReactionProcessVessel.find_by(
    #     reaction_process: reaction_process, vessel: new_vessel,
    #   )
    #   save
    # end

    def append_action(action_params, insert_before)
      return create_transfer_target_action(action_params.workup) if action_params.action_name == 'TRANSFER'

      action = reaction_process_actions.new(
        position: reaction_process_actions.count,
      )

      action.update_by_params action_params

      action.update_position(insert_before) if insert_before

      action
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

      steps
    end

    def added_materials(material_type)
      added_material_ids = reaction_process.reaction_process_steps.where('position <= ?',
                                                                         position).map do |process_step|
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

    def saved_sample_ids
      reaction_process_actions.select do |action|
        action.action_name == 'SAVE'
      end.map { |action| action.workup['sample_id'] }
    end

    private

    def create_transfer_target_action(workup)
      target_step = ReactionProcessStep.find workup['transfer_target_step_id']

      new_action = ReactionProcessAction.new(action_name: 'TRANSFER', workup: workup)

      sample = Sample.find_by(id: workup['sample_id'])

      new_action.position = target_step.reaction_process_actions.count
      new_action.workup['description'] = "from #{label}:"
      new_action.workup['description'] += " #{sample.preferred_label || sample.short_label}"
      new_action.workup['description'] += " #{workup['transfer_percentage']}%"
      target_step.reaction_process_actions << new_action
      new_action
    end

    def add_actions_acting_as(material_type)
      add_actions.select { |action| action.workup['acts_as'] == material_type }
    end

    def add_actions
      @add_actions ||= reaction_process_actions.select { |action| action.action_name == 'ADD' }
    end

    def calculate_action_post_conditions
      current_conditions = initial_conditions

      reaction_process_actions.order(:position).map do |activity|
        if activity.is_condition?
          current_conditions.each do |key, current_condition|
            current_conditions[key] = activity.workup[key] || current_condition || {}
          end
        end
        current_conditions.dup
      end
    end

    def initial_conditions
      # TODO: Will be enhanced by fallback to user default conditions.
      ReactionProcessEditor::SelectOptions.instance
                                          .global_default_conditions
                                          .merge(reaction_process.default_conditions.to_h)
    end
  end
end
