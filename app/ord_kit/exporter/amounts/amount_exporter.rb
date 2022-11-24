# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class AmountExporter < OrdKit::Exporter::Amounts::Base
        def to_ord
          case unit
          when 'l', 'ml', 'mcl', 'nl'
            OrdKit::Amount.new(
              volume_includes_solutes: volume_includes_solutes,
              volume: VolumeExporter.new(
                value: value,
                unit: unit,
              ).to_ord,
            )
          when 'kg', 'g', 'mg', 'mcg'
            OrdKit::Amount.new(
              volume_includes_solutes: volume_includes_solutes,
              mass: MassExporter.new(
                value: value,
                unit: unit,
              ).to_ord,
            )
          when 'mol', 'mmol', 'mcmol', 'nanomol'
            OrdKit::Amount.new(
              volume_includes_solutes: volume_includes_solutes,
              moles: MolesExporter.new(
                value: value,
                unit: unit,
              ).to_ord,
            )
          when '%', 'percent'
            OrdKit::Amount.new(
              volume_includes_solutes: volume_includes_solutes,
              percentage: PercentageExporter.new(
                value: value,
              ).to_ord,
            )
          end
        end

        private

        attr_reader :value, :unit

        def volume_includes_solutes
          nil # hardcoded empty. Unknown in ELN.
        end
      end
    end
  end
end
