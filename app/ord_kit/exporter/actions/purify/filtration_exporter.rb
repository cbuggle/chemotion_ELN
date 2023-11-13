# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      module Purify
        class FiltrationExporter < OrdKit::Exporter::Actions::Purify::Base
          def to_ord
            {
              filtration: OrdKit::ReactionProcessAction::ActionFiltration.new(
                filtration_mode: filtration_mode,
                steps: steps,
              ),
            }
          end

          private

          def filtration_mode
            OrdKit::ReactionProcessAction::ActionFiltration::FiltrationMode.const_get workup['filtration_mode'].to_s
          rescue NameError
            OrdKit::ReactionProcessAction::ActionFiltration::FiltrationMode::UNSPECIFIED
          end

          def steps
            workup['filtration_steps'].map do |filtration_step|
              OrdKit::ReactionProcessAction::ActionFiltration::FiltrationStep.new(
                solvents: solvents_with_ratio(filtration_step['solvents']),
                amount: Metrics::AmountExporter.new(filtration_step['amount']).to_ord,
                repetitions: filtration_step['repetitions']['value'],
                rinse_vessel: filtration_step['rinse_vessel'],
              )
            end
          end

          def solvents_with_ratio(solvents)
            solvents.map do |solvent|
              OrdKit::CompoundWithRatio.new(
                compound: OrdKit::Exporter::Compounds::PurifySolventExporter.new(solvent['id']).to_ord,
                ratio: solvent['ratio'].to_s,
              )
            end
          end

          def ratio
            workup['purify_ratio']
          end
        end
      end
    end
  end
end
