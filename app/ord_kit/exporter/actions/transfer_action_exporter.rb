# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class TransferActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            transfer: ReactionActionTransfer.new(
              sample: sample,
              transfer_source_reaction_step_id: transfer_source_reaction_step_id,
              transfer_target_reaction_step_id: transfer_target_reaction_step_id,
              amount: amount,
            ),
          }
        end

        def sample
          OrdKit::Exporter::Compounds::TransferCompoundExporter.new(model).to_ord
        end

        def transfer_source_reaction_step_id
          ris = ReactionsIntermediateSample.find_by(sample: model.sample, reaction: model.reaction)

          return unless ris.reaction_step

          model.reaction_process.reaction_process_steps[ris.reaction_step - 1]&.id
        end

        def transfer_target_reaction_step_id
          workup['transfer_target_step_id']
        end

        def amount
          Amounts::AmountExporter.new(
            value: workup['transfer_percentage'],
            unit: 'percent',
          ).to_ord
        end
      end
    end
  end
end
