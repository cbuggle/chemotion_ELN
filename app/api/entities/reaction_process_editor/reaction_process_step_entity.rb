# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessStepEntity < Grape::Entity
      expose(
        :id, :name, :position, :locked, :reaction_process_id, :reaction_id,
        :label, :final_conditions, :select_options, :automation_status
      )

      expose :activities, using: 'Entities::ReactionProcessEditor::ReactionProcessActivityEntity'

      expose :reaction_process_vessel, using: 'Entities::ReactionProcessEditor::ReactionProcessVesselEntity'

      private

      def select_options
        SelectOptions::ReactionProcessStep.new.select_options_for(reaction_process_step: object)
      end

      def automation_status
        return "STEP_COMPLETED" if object.reaction_process_activities.all?(&:automation_completed?)
        return "STEP_RUNNING" unless object.predecessors.any?(&:halts_automation?)

        object.automation_status || "STEP_HALT_BY_PRECEDING"
      end

      def reaction
        object.reaction
      end

      def activities
        object.reaction_process_activities.order('position')
      end

      def reaction_id
        reaction.id
      end
    end
  end
end
