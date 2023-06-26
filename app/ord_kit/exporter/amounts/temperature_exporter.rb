# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class TemperatureExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_TEMPERATURE_UNIT = 'CELSIUS'

        def to_ord
          OrdKit::Temperature.new(
            value: value.to_f,
            precision: nil, # hardcoded empty
            units: temperature_unit,
          )
        end

        private

        attr_reader :value, :unit

        def temperature_unit
          OrdKit::Temperature::TemperatureUnit.const_get ELN_DEFAULT_TEMPERATURE_UNIT
        end
      end
    end
  end
end
