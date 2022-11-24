# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionExporter < OrdKit::Exporter::Base
        # Our KIT-ORD relevant data is stored in the ReactionProcess <-1:1-> Reaction
        # This is why we user the reaction_process.id (which is a UUID).

        def to_ord
          OrdKit::Reaction.new(
            # TODO: Fill all the nils!
            identifiers: nil,
            inputs: {},
            setup: nil,
            conditions: nil,
            observations: nil,
            notes: nil,
            workups: nil,
            outcomes: nil,
            provenance: nil,
            reaction_id: model.reaction_process.id,
            reaction_steps: ReactionProcessExporter.new(model.reaction_process).to_ord,
          )
        end
      end
    end
  end
end
