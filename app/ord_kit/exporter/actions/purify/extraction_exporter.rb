# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      module Purify
        class ExtractionExporter < OrdKit::Exporter::Actions::Purify::Base
          def to_ord
            {
              extraction: {
                solvents: solvents,
                ratio: ratio,
              },
            }
          end

          private

          def solvents
            Array(workup['purify_solvent_sample_ids']).filter_map do |sample_id|
              OrdKit::Exporter::Compounds::PurifySolventExporter.new(sample_id).to_ord
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
