# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Automation < Base
          def all
            { FORMS: {
              ANALYSIS: { CHROMATOGRAPHY: chromatography_layout },
              PURIFICATION: { CHROMATOGRAPHY: chromatography_layout },
            } }
          end

          private

          def chromatography_layout
            chromatography_layout_csv.map do |layout_csv|
              {
                value: layout_csv['property'],
                label: layout_csv['label_UI'],
                link: layout_csv['link'],
              }
            end
          end

          def chromatography_layout_csv
            SelectOptions::Importer::CsvFile.new.read(:layout)
          end
        end
      end
    end
  end
end
