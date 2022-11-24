# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class PhAdjustConditionsExporter < OrdKit::Exporter::Base
        # Works on ReactionProcessAction "CONDITION / PH"

        def to_ord
          OrdKit::PhAdjustConditions.new(
            measurement_type: measurement_type,
            ph: model.workup['condition_value'].to_f,
          )
        end

        private

        def measurement_type
          OrdKit::PhAdjustConditions::PhAdjustMeasurementType.const_get workup['condition_additional_information']
        rescue NameError
          OrdKit::PhAdjustConditions::PhAdjustMeasurementType::UNSPECIFIED
        end
      end
    end
  end
end
