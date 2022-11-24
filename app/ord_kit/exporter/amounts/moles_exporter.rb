# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class MolesExporter < OrdKit::Exporter::Amounts::Base
        ORD_UNIT_MAPPING = {
          UNSPECIFIED: 'UNSPECIFIED',
          mol: 'MOLE',
          mmol: 'MILLIMOLE',
          mcmol: 'MICROMOLE',
          nmol: 'NANOMOLE',
        }.stringify_keys.freeze

        def to_ord
          OrdKit::Moles.new(
            value: value.to_f,
            precision: nil,
            units: units,
          )
        end

        private

        def units
          OrdKit::Moles::MolesUnit.const_get ORD_UNIT_MAPPING[unit].to_s
        rescue NameError
          OrdKit::Moles::MolesUnit::UNSPECIFIED
        end
      end
    end
  end
end
