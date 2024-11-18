# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Importer
        class Ontologies
          ROOT_DIR = ENV.fetch('REACTION_PROCESS_EDITOR_DATA_DIR', nil)
          FILES = 'ontologies/*.csv'

          def read
            all_csv
          end

          private

          # def all_csv
          #   @all_csv = []
          #   @all_csv << read_csv(filename).to_a }
          # end

          def all_csv
            csv = []
            filenames.each do |filename|
              # Rails.logger.debug { "parsing #{filename.read}" }
              CSV.foreach(filename, col_sep: ';', headers: true, return_headers: false,
                                    converters: [->(string) { string&.strip }]) do |row|
                csv << row
              end
            end
            csv
          end

          def filenames
            Rails.root.glob("#{ROOT_DIR}/#{FILES}")
          end
        end
      end
    end
  end
end
