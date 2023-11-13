# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class PressureConditionsExporter < OrdKit::Exporter::Conditions::Base
        # Works on ReactionProcessAction ("CONDITION / PRESSURE")

        def to_ord
          OrdKit::PressureConditions.new(
            control: control,
            setpoint: setpoint || OrdKit::Pressure.new,
            atmosphere: atmosphere,
            measurements: measurements,
          )
        end

        private

        def control
          nil # n/a. Unknown in ELN.
        end

        def setpoint
          return unless condition['value']

          # For now we work only with bars / millibars.

          OrdKit::Pressure.new(
            value: condition['value'].to_f,
            precision: nil, # TODO:
            units: OrdKit::Pressure::PressureUnit.const_get(condition['unit']),
          )
        end

        def atmosphere
          nil # n/a. Unknown in ELN.
        end

        def measurements
          nil # n/a. Unknown in ELN.
        end
      end
    end
  end
end
