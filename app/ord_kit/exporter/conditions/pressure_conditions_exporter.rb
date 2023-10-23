# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class PressureConditionsExporter < OrdKit::Exporter::Base
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
          return unless model['value']

          # For now we work only with bars / millibars.
          unit = OrdKit::Pressure::PressureUnit::BAR
          value = model['value'].to_f / 1000

          OrdKit::Pressure.new(
            value: value.to_f,
            precision: 3, # TODO: Check .
            units: unit,
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
