# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionEnvironmentExporter < OrdKit::Exporter::Base
        # All the ORD reaction environment is stored in our Vessel.

        def to_ord
          return unless vessel

          OrdKit::ReactionSetup::ReactionEnvironment.new(
            details: vessel.details,
            type: reaction_environment,
          )
        end

        private

        def reaction_environment
          OrdKit::ReactionSetup::ReactionEnvironment::ReactionEnvironmentType.const_get vessel.environment_type
        rescue StandardError
          OrdKit::ReactionSetup::ReactionEnvironment::ReactionEnvironmentType::UNSPECIFIED
        end

        def vessel
          model.vessel
        end
      end
    end
  end
end
