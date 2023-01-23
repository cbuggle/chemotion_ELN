# frozen_string_literal: true

module Entities
  class ReactionProcessActionEntity < ApplicationEntity
    expose(:id, :action_name, :position, :workup, :action_number, :label,
           :starts_at, :ends_at, :duration, :start_time, :min_position, :max_position)

    expose! :sample, using: 'Entities::SampleEntity'
    expose! :medium, using: 'Entities::ReactionMediumEntity'

    private

    def min_position
      return 0 unless object.action_name == 'CONDITION_END'

      ReactionProcessAction.find(object.workup['condition_start_id']).position + 1
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Action #{object.id} is CONDITION_END without corresponding CONDITION (id: #{object.workup['condition_start_id']})")
      0
    end

    def max_position
      return object.reaction_process_step.last_action_position unless object.action_name == 'CONDITION'

      ReactionProcessAction.find(object.workup['condition_end_id']).position - 1
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Action #{object.id} is CONDITION without corresponding CONDITION_END (id: #{object.workup['condition_end_id']})")
      object.reaction_process_step.last_action_position
    end

    def start_time
      object.start_time || 0
    end

    def duration
      object.duration || 0
    end

    def action_number
      object.position + 1
    end
  end
end
