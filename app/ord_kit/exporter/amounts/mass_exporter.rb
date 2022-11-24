# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class MassExporter < OrdKit::Exporter::Amounts::Base
        ORD_UNIT_MAPPING = {
          UNSPECIFIED: 'UNSPECIFIED',
          kg: 'KILOGRAM',
          g: 'GRAM',
          mg: 'MILLIGRAM',
          mcg: 'MICROGRAM',
        }.stringify_keys.freeze

        def to_ord
          OrdKit::Mass.new(
            value: value.to_f,
            precision: nil,
            units: units,
          )
        end

        private

        def units
          OrdKit::Mass::MassUnit.const_get ORD_UNIT_MAPPING[unit].to_s
        rescue NameError
          OrdKit::Mass::MassUnit::UNSPECIFIED
        end
      end
    end
  end
end
