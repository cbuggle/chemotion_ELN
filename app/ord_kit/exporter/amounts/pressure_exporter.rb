# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class PressureExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_PRESSURE_UNIT = 'BAR'

        def to_ord
          return unless value

          OrdKit::Pressure.new(
            value: value.to_f / 1000,
            precision: 10, # TODO: Check .
            units: pressure_unit,
          )
        end

        private

        def pressure_unit
          OrdKit::Pressure::PressureUnit.const_get ELN_DEFAULT_PRESSURE_UNIT
        end
      end
    end
  end
end
