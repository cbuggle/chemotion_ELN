# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessVesselEntity < Grape::Entity
      expose(:id, :preparations)

      expose :vessel, using: 'Entities::ReactionProcessEditor::VesselEntity'
      expose :step_names

      private

      def preparations
        object.preparations || []
      end

      def step_names
        object.reaction_process.reaction_process_steps.where(vessel_id: object.vessel.id).order(:position).map(&:name)
      end
    end
  end
end
