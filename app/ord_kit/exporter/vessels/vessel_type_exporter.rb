# frozen_string_literal: true

module OrdKit
  module Exporter
    module Vessels
      class VesselTypeExporter < OrdKit::Exporter::Base
        def to_ord
          OrdKit::Vessel::VesselType.const_get model.vessel_type
        rescue NameError
          OrdKit::Vessel::VesselType::UNSPECIFIED
        end
      end
    end
  end
end
