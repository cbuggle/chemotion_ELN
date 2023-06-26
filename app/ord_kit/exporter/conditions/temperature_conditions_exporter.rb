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
            value: model['value'],
            unit: model['unit'],
          ).to_ord
        end

        def temperature_control
          return unless model['additional_information']

          OrdKit::TemperatureConditions::TemperatureControl.new(
            type: temperature_control_type,
            details: nil, # n/a. Unknown in ELN.
          )
        end

        def measurements
          nil # n/a. Unknown in ELN.
        end

        def temperature_control_type
          OrdKit::TemperatureConditions::TemperatureControl::TemperatureControlType.const_get model['additional_information']
        rescue NameError
          OrdKit::TemperatureConditions::TemperatureControl::TemperatureControlType::UNSPECIFIED
        end
      end
    end
  end
end
