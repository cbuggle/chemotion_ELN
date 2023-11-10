# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class IrradiationConditionsExporter < OrdKit::Exporter::Base
        # Works on ReactionProcessAction "CONDITION / IRRADIATION"

        ELN_DEFAULT_WAVELENGTH_TYPE =
          ELN_DEFAULT_POWER_UNIT = 'WATT'

        def to_ord
          OrdKit::IlluminationConditions.new(
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
          OrdKit::IlluminationConditions::IlluminationType.const_get model['additional_information']
        rescue NameError
          OrdKit::IlluminationConditions::IlluminationType::UNSPECIFIED
        end

        def details
          nil # n/a. Unknown in ELN.
        end

        def peak_wavelength
          Wavelength.new(
            value: model['value'].to_i,
            precision: nil, # n/a. Unkown in ELN.
            # Only allowed are NANOMETER and WAVENUMBER (its inverse), WAVENUMBER is unknown in ELN.
            # TODO: We now have the unit in the workup
            units: OrdKit::Wavelength::WavelengthUnit::NANOMETER,
          )
        end

        def color
          nil # n/a. Unkown in ELN
        end

        def distance_to_vessel
          nil # n/a. Unknown in ELN
        end

        def power
          return unless model['power']

          # TODO: We now have the unit in the workup
          OrdKit::Exporter::Amounts::PowerExporter.new(value: model['power']['value'],
                                                       unit: ELN_DEFAULT_POWER_UNIT).to_ord
        end

        def power_end
          return unless power_is_ramp && model['power_end']

          # TODO: We now have the unit in the workup
          OrdKit::Exporter::Amounts::PowerExporter.new(value: model['power_end']['value'],
                                                       unit: ELN_DEFAULT_POWER_UNIT).to_ord
        end

        def power_is_ramp
          model['power_is_ramp']
        end
      end
    end
  end
end
