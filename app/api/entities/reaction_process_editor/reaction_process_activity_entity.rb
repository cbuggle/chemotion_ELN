# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessActivityEntity < Grape::Entity
      expose(:id, :step_id, :activity_name, :position, :workup)

      expose :sample, using: 'Entities::ReactionProcessEditor::SampleEntity'
      expose :medium, using: 'Entities::ReactionProcessEditor::MediumEntity'

      expose :preconditions

      expose :intermediate_type, :transfer_source_step_name # supportive piggybacks required in TRANSFER only

      expose :reaction_process_vessel, using: 'Entities::ReactionProcessEditor::ReactionProcessVesselEntity'

      private

      def intermediate_type
        return unless object.transfer? && object.sample

        ReactionsIntermediateSample.find_by(reaction: object.reaction, sample: object.sample)&.intermediate_type
      end

      def transfer_source_step_name
        return unless object.transfer?

        ris = ReactionsIntermediateSample.find_by(sample: object.sample, reaction: object.reaction)

        ris&.reaction_process_step&.name
      end

      def preconditions
        reaction_process_step.activity_preconditions[object.position]
      end

      def reaction_process_step
        @reaction_process_step ||= object.reaction_process_step
      end

      def step_id
        object.reaction_process_step_id
      end
    end
  end
end
