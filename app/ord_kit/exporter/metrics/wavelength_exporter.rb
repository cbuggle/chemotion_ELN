# frozen_string_literal: true

module OrdKit
  module Exporter
    module Metrics
      class WavelengthExporter < OrdKit::Exporter::Metrics::Base
        def to_ord
          Wavelength.new(
            value: value.to_f,
            precision: nil,
            units: units,
          )
        end

        private

        def units
          Wavelength::WavelengthUnit.const_get unit
        rescue NameError
          Wavelength::WavelengthUnit::UNSPECIFIED
        end
      end
    end
  end
end
