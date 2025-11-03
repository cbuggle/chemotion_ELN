# frozen_string_literal: true

module OrdKit
  module Exporter
    class ReactionProcessExporter < Base
      # Our KIT-ORD relevant data is stored in the ReactionProcess <-1:1-> Reaction
      # This is why we use the reaction_process.id (which is a UUID) instead of reaction.id,
      # (which is a sequential Integer which we certainly do not want to publish). cbuggle, 2022-02-11.
      def to_ord
        OrdKit::Reaction.new(
          # TODO: Fill all the nils!
          reaction_id: model.id,
          conditions: conditions,
          provenance: OrdKit::Exporter::Reactions::ReactionProvenanceExporter.new(
            model.provenance,
          ).to_ord,
          reaction_steps: OrdKit::Exporter::Reactions::ReactionProcessExporter.new(model).to_ord,
        )
      end

      private

      def conditions
        OrdKit::Exporter::Conditions::ReactionConditionsExporter.new(model.initial_conditions).to_ord
      end
    end
  end
end
