# frozen_string_literal: true

module Entities
  class SamplePreparationEntity < ApplicationEntity
    expose(:id, :sample_id, :preparations, :equipment, :details)

    private

    def preparations
      object.preparations || []
    end

    def equipment
      object.equipment || []
    end
  end
end
