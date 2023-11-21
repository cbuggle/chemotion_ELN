# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      module Purify
        class ExtractionExporter < OrdKit::Exporter::Actions::Purify::Base
          def to_ord
            {
              extraction: {
                solvents: solvents_with_ratio(workup['solvents']),
                amount: Metrics::AmountExporter.new(workup['amount']).to_ord,
                phase: extraction_phase,
              },
            }
          end

          def solvents_with_ratio(solvents)
            solvents&.map do |solvent|
              OrdKit::CompoundWithRatio.new(
                compound: OrdKit::Exporter::Compounds::PurifySampleOrDiverseSolventExporter.new(solvent['id']).to_ord,
                ratio: solvent['ratio'].to_s,
              )
            end
          end

          def extraction_phase
            ReactionProcessAction::ActionExtraction::ExtractionPhase.const_get workup['phase'].to_s
          rescue NameError
            ReactionProcessAction::ActionExtraction::ExtractionPhase::UNSPECIFIED
          end
        end
      end
    end
  end
end
