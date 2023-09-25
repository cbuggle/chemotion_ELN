# frozen_string_literal: true

module Entities
  module ProcessEditor
    class ReactionProcessActionEntity < ApplicationEntity
      expose(:id, :step_id, :action_name, :position, :workup, :sample_names,
             :starts_at, :ends_at, :duration, :start_time)

      expose :sample, using: 'Entities::ProcessEditor::SampleEntity'
      expose :medium, using: 'Entities::ProcessEditor::ReactionMediumEntity'

      expose :current_conditions, :pre_conditions, :post_conditions

      private

      def sample_names
        # Supportive attribute for easy display in frontend.
        names = []
        names << object.sample.preferred_label if object.has_sample?
        names << object.medium.preferred_label if object.has_medium?
        names << Sample.where(id: object.workup['purify_solvent_sample_ids']).map(&:preferred_label)
        names.join(' ')
      end

      def step_id
        object.reaction_process_step_id
      end

      def start_time
        object.start_time || 0
      end

      def duration
        object.duration || 0
      end

      def current_conditions
        # probably obsolete, keeping provisionally  for UI backwards compatibility
        reaction_process_step.action_post_conditions[object.position]
      end

      def post_conditions
        # probably obsolete, keeping provisionally  for UI backwards compatibility
        reaction_process_step.action_post_conditions[object.position]
      end

      def pre_conditions
        reaction_process_step.action_pre_conditions[object.position]
      end

      def reaction_process_step
        @reaction_process_step ||= object.reaction_process_step
      end
    end
  end
end
