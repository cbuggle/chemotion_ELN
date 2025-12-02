# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Vessels < Base
          def preparation_options
            { preparation_types: preparation_types, cleanup_types: cleanup_types }
          end

          def preparation_types
            titlecase_options_for ['OVEN_DRIED', 'FLAME_DRIED', 'EVACUATED_BACKFILLED', 'PURGED', 'CUSTOM', 'NONE']
            # OrdKit::VesselPreparation::VesselPreparationType.constants
          end

          def cleanup_types
            titlecase_options_for ['WASTE', 'REMOVE', 'STORAGE']
            # OrdKit::VesselCleanup::VesselCleanupType.constants
          end
        end
      end
    end
  end
end
