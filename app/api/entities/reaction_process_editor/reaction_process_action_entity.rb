# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessActionEntity < Grape::Entity
      expose(:id, :step_id, :action_name, :position, :workup, :sample_names)

      expose :sample, using: 'Entities::ReactionProcessEditor::SampleEntity'
      expose :medium, using: 'Entities::ReactionProcessEditor::ReactionMediumEntity'

      expose :pre_conditions

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

      def pre_conditions
        reaction_process_step.action_pre_conditions[object.position]
      end

      def reaction_process_step
        @reaction_process_step ||= object.reaction_process_step
      end
    end
  end
end
