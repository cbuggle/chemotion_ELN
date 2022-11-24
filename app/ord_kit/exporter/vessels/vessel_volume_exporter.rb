# frozen_string_literal: true

module OrdKit
  module Exporter
    module Vessels
      class VesselVolumeExporter < OrdKit::Exporter::Base
        def to_ord
          Amounts::VolumeExporter.new(
            value: model.volume_amount,
            unit: model.volume_unit,
          ).to_ord
        end
      end
    end
  end
end
