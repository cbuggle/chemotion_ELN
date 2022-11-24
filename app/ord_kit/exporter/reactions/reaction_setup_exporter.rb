# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionSetupExporter < OrdKit::Exporter::Base
        # All the ORD reaction setup is stored in our Vessel.
        def to_ord
          return unless vessel

          OrdKit::ReactionSetup.new(
            vessel: Vessels::VesselExporter.new(vessel).to_ord,
            is_automated: is_automated?,
            automation_platform: '', # hardcoded empty. Unknown in ELN.
            automation_code: {}, # hardcoded empty. Unknown in ELN.
            environment: ReactionEnvironmentExporter.new(model).to_ord,
          )
        end

        private

        def vessel
          model.vessel
        end

        def is_automated?
          vessel.automation_type == 'AUTOMATIC'
        end
      end
    end
  end
end
