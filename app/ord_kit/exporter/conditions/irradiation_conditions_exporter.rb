# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class IrradiationConditionsExporter < OrdKit::Exporter::Base
        # Works on ReactionProcessAction "CONDITION / IRRADIATION"

        ELN_DEFAULT_WAVELENGTH_TYPE = OrdKit::Wavelength::WavelengthUnit::NANOMETER

        def to_ord
          OrdKit::IlluminationConditions.new(
            type: irradiation_type,
            details: details,
            peak_wavelength: peak_wavelength,
            color: color,
            distance_to_vessel: distance_to_vessel,
          )
        end

        private

        def irradiation_type
          OrdKit::IlluminationConditions::IlluminationType.const_get workup['condition_additional_information']
        rescue NameError
          OrdKit::IlluminationConditions::IlluminationType::UNSPECIFIED
        end

        def details
          nil # n/a. Unknown in ELN.
        end

        def peak_wavelength
          Wavelength.new(
            value: model.workup['condition_value'].to_i,
            precision: nil, # n/a. Unkown in ELN.
            units: ELN_DEFAULT_WAVELENGTH_TYPE,
          )
        end

        def color
          nil # n/a. Unkown in ELN
        end

        def distance_to_vessel
          nil # n/a. Unknown in ELN
        end
      end
    end
  end
end
