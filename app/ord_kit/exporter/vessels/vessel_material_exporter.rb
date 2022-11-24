# frozen_string_literal: true

module OrdKit
  module Exporter
    module Vessels
      class VesselMaterialExporter < OrdKit::Exporter::Base
        MATERIAL_MAPPING = {
          MATERIAL_UNSPECIFIED: OrdKit::VesselMaterial::VesselMaterialType::UNSPECIFIED,
          MATERIAL_CUSTOM: OrdKit::VesselMaterial::VesselMaterialType::CUSTOM,
          GLASS: OrdKit::VesselMaterial::VesselMaterialType::GLASS,
          POLYPROPYLENE: OrdKit::VesselMaterial::VesselMaterialType::POLYPROPYLENE,
          PLASTIC: OrdKit::VesselMaterial::VesselMaterialType::PLASTIC,
          METAL: OrdKit::VesselMaterial::VesselMaterialType::METAL,
          QUARTZ: OrdKit::VesselMaterial::VesselMaterialType::QUARTZ,
          BROWN_GLASS: OrdKit::VesselMaterial::VesselMaterialType::BROWN_GLASS,
          PFA: OrdKit::VesselMaterial::VesselMaterialType::PFA,
          PTFE: OrdKit::VesselMaterial::VesselMaterialType::PTFE,
        }.stringify_keys.freeze

        def to_ord
          OrdKit::VesselMaterial.new(
            type: MATERIAL_MAPPING[model.material_type] || OrdKit::VesselMaterial::VesselMaterialType::UNSPECIFIED,
            details: model.details,
          )
        end
      end
    end
  end
end
