# frozen_string_literal: true

module Entities
  class ReactionProcessActionEntity < ApplicationEntity
    expose(:id, :step_id, :action_name, :position, :workup, :activity_number, :sample_names,
           :starts_at, :ends_at, :duration, :start_time, :min_position, :max_position)

    expose :sample, using: 'Entities::SampleEntity'
    expose :medium, using: 'Entities::ReactionMediumEntity'

    private

    def sample_names
      # Supporting attribute for easy display in frontend.
      names = []
      names << object.sample.preferred_label if object.has_sample?
      names << object.medium.preferred_label if object.has_medium?
      names << Sample.where(id: object.workup['purify_solvent_sample_ids']).map(&:short_label)
      names.join(' ')
    end

    def step_id
      object.reaction_process_step_id
    end

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
  end
end
