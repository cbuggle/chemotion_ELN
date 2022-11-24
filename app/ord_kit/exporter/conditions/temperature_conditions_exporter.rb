# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class TemperatureConditionsExporter < OrdKit::Exporter::Base
        # Works on ReactionProcessAction ("CONDITION / TEMPERATURE")

        def to_ord
          OrdKit::TemperatureConditions.new(
            control: temperature_control,
            setpoint: setpoint,
            measurements: measurements,
          )
        end

        private

        def setpoint
          OrdKit::Exporter::Amounts::TemperatureExporter.new(
            value: model.workup['condition_value'],
            unit: model.workup['condition_unit'],
          ).to_ord
        end

        def temperature_control
          return unless model.workup['condition_additional_information']

          OrdKit::TemperatureConditions::TemperatureControl.new(
            type: temperature_control_type,
            details: nil, # n/a. Unknown in ELN.
          )
        end

        def measurements
          nil # n/a. Unknown in ELN.
        end

        def temperature_control_type
          OrdKit::TemperatureConditions::TemperatureControl::TemperatureControlType.const_get model.workup['condition_additional_information']
        rescue NameError
          OrdKit::TemperatureConditions::TemperatureControl::TemperatureControlType::UNSPECIFIED
        end
      end
    end
  end
end
