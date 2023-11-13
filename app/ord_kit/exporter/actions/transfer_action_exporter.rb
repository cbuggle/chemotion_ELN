# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class TransferActionExporter < OrdKit::Exporter::Actions::Base
        private

        def action_type_attributes
          {
            transfer: OrdKit::ReactionProcessAction::ActionTransfer.new(
              input: sample,
              transfer_source_reaction_step_id: transfer_source_reaction_step_id,
              transfer_target_reaction_step_id: transfer_target_reaction_step_id,
              amount: amount,
              percentage: percentage,
            ),
          }
        end

        def sample
          OrdKit::Exporter::Samples::TransferSampleExporter.new(action).to_ord
        end

        def transfer_source_reaction_step_id
          ris = ReactionsIntermediateSample.find_by(sample: action.sample, reaction: action.reaction)

          return unless ris.reaction_step

          # source_step is stored only as index (1-indexed) in its reaction_step (for human readability in ELN).
          # We might want to add :reaction_step_id to ReactionsIntermediateSample to clarify code.
          action.siblings[ris.reaction_step - 1]&.id
        end

        def transfer_target_reaction_step_id
          workup['transfer_target_step_id']
        end

        def amount
          Metrics::AmountExporter.new(workup['target_amount']).to_ord
        end

        def percentage
          # percentag redundantly denotes the fraction of the original sample amount, piggybacked onto target_amount.
          percentage_workup = { value: workup.dig('target_amount', 'percentage'), unit: 'PERCENT' }.stringify_keys
          Metrics::Amounts::PercentageExporter.new(percentage_workup).to_ord
        end
      end
    end
  end
end
