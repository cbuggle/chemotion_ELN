# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class VolumeExporter < OrdKit::Exporter::Amounts::Base
        ORD_UNIT_MAPPING = {
          UNSPECIFIED: 'UNSPECIFIED',
          l: 'LITER',
          ml: 'MILLILITER',
          mcl: 'MICROLITER',
          nl: 'NANOLITER',
        }.freeze

        def to_ord
          OrdKit::Volume.new(
            value: value.to_f,
            precision: nil,
            units: units,
          )
        end

        private

        def units
          OrdKit::Volume::VolumeUnit.const_get ORD_UNIT_MAPPING[unit].to_s
        rescue NameError
          OrdKit::Volume::VolumeUnit::UNSPECIFIED
        end
      end
    end
  end
end
