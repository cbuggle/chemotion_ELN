# frozen_string_literal: true

module Entities
  module ProcessEditor
    class SamplePreparationEntity < ApplicationEntity
      expose(:id, :sample_id, :preparations, :equipment, :details)

      expose! :sample, using: 'Entities::ProcessEditor::SampleEntity'

      private

      def preparations
        object.preparations || []
      end

      def equipment
        object.equipment || []
      end
    end
  end
end
