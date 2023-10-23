# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class TransferActionExporter < OrdKit::Exporter::Actions::Base
        private

        def action_type_attributes
          {
            transfer: ReactionActionTransfer.new(
              input: sample,
              transfer_source_reaction_step_id: transfer_source_reaction_step_id,
              transfer_target_reaction_step_id: transfer_target_reaction_step_id,
              amount: amount,
            ),
          }
        end

        def sample
          OrdKit::Exporter::Samples::TransferSampleExporter.new(model).to_ord
        end

        def transfer_source_reaction_step_id
          ris = ReactionsIntermediateSample.find_by(sample: model.sample, reaction: model.reaction)

          return unless ris.reaction_step

          # source_step is stored only as index (1-indexed) in its reaction_step (for human readability in ELN).
          # We might want to add :reaction_step_id to ReactionsIntermediateSample to clarify code.
          model.siblings[ris.reaction_step - 1]&.id
        end

        def transfer_target_reaction_step_id
          workup['transfer_target_step_id']
        end

        def amount
          Amounts::AmountExporter.new(
            value: workup['transfer_percentage'],
            unit: 'PERCENT',
          ).to_ord
        end
      end
    end
  end
end
