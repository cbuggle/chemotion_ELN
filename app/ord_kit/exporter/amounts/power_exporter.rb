# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class PowerExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_POWER_UNIT = 'WATT'

        def to_ord
          OrdKit::Power.new(
            value: value.to_f,
            precision: nil,
            units: units,
          )
        end

        private

        def units
          OrdKit::Power::PowerUnit.const_get ELN_DEFAULT_POWER_UNIT
        rescue NameError
          OrdKit::Power::PowerUnit::UNSPECIFIED
        end
      end
    end
  end
end
