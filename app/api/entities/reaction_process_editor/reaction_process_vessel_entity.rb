# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class ReactionProcessVesselEntity < Grape::Entity
      expose(:id, :preparations)

      expose :vessel, using: 'Entities::ReactionProcessEditor::VesselEntity'

      private

      def preparations
        object.preparations || []
      end
    end
  end
end
