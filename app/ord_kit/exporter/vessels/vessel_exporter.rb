# frozen_string_literal: true

module OrdKit
  module Exporter
    module Vessels
      class VesselExporter < OrdKit::Exporter::Base
        def to_ord
          # TODO! This is actually an error when ProcedureStep has no vessel set.
          return unless model

          # ORD export is not allowed and not possible without vessel,
          # we need to capture this beforehand.
          # cbuggle, 5.1.2022.

          OrdKit::Vessel.new(
            type: VesselTypeExporter.new(model).to_ord,
            details: model.details,
            material: VesselMaterialExporter.new(model).to_ord,
            preparations: preparations,
            attachments: VesselAttachmentsExporter.new(model).to_ord,
            volume: VesselVolumeExporter.new(model).to_ord,
            plate_id: nil, # TODO: hardcoded empty
            plate_position: nil, # TODO: hardcoded empty
          )
        end

        private

        def preparations
          VesselPreparationsExporter.new(model).to_ord
        end
      end
    end
  end
end
