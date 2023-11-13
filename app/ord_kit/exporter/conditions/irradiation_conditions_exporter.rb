# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class IrradiationConditionsExporter < OrdKit::Exporter::Conditions::Base
        # Works on ReactionProcessAction "CONDITION / IRRADIATION"
        def to_ord
          IlluminationConditions.new(
            type: irradiation_type,
            details: details,
            peak_wavelength: peak_wavelength,
            color: color,
            distance_to_vessel: distance_to_vessel,
            power: power,
            power_is_ramp: power_is_ramp,
            power_end: power_end,
          )
        end

        private

        def irradiation_type
          IlluminationConditions::IlluminationType.const_get condition['additional_information']
        rescue NameError
          IlluminationConditions::IlluminationType::UNSPECIFIED
        end

        def details
          nil # n/a. Unknown in ELN.
        end

        def peak_wavelength
          Exporter::Metrics::WavelengthExporter.new(condition).to_ord
          # WavelengthExporter.new.to_ord
        end

        def color
          nil # n/a. Unkown in ELN
        end

        def distance_to_vessel
          nil # n/a. Unknown in ELN
        end

        def power
          return unless condition['power']

          Exporter::Metrics::PowerExporter.new(condition['power']).to_ord
        end

        def power_end
          return unless power_is_ramp && condition['power_end']

          Exporter::Metrics::PowerExporter.new(condition['power_end']).to_ord
        end

        def power_is_ramp
          condition['power_is_ramp']
        end
      end
    end
  end
end
