# frozen_string_literal: true

module Entities
  module ProcessEditor
    class ReactionProcessActionEntity < ApplicationEntity
      expose(:id, :step_id, :action_name, :position, :workup, :activity_number, :sample_names,
             :starts_at, :ends_at, :duration, :start_time, :min_position, :max_position)

      expose :sample, using: 'Entities::ProcessEditor::SampleEntity'
      expose :medium, using: 'Entities::ProcessEditor::ReactionMediumEntity'

      private

      def sample_names
        # Supporting attribute for easy display in frontend.
        names = []
        names << object.sample.preferred_label if object.has_sample?
        names << object.medium.preferred_label if object.has_medium?
        names << Sample.where(id: object.workup['purify_solvent_sample_ids']).map(&:preferred_label)
        names.join(' ')
      end

      def step_id
        object.reaction_process_step_id
      end

      def min_position
        0
      end

      def max_position
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
end
