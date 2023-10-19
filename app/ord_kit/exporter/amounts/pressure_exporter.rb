# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class PressureExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_PRESSURE_UNIT = 'BAR'

        def to_ord
          return unless value

          OrdKit::Pressure.new(
            # ORD has only BAR, no MBAR. We use only MBAR in ELN. We need to convert.
            value: value.to_f / 1000,
            precision: nil,
            units: OrdKit::Pressure::PressureUnit.const_get(ELN_DEFAULT_PRESSURE_UNIT),
          )
        end
      end
    end
  end
end
