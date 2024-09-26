# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Importer
        class Devices < Base
          include Singleton

          ROOT_DIR = ENV.fetch('REACTION_PROCESS_EDITOR_DATA_DIR', nil)
          DEVICES_FILENAME = ENV.fetch('REACTION_PROCESS_EDITOR_DEVICES_FILENAME', '')

          def devices_csv
            CSV.parse(read_devices_file, col_sep: ';', headers: true, return_headers: false)
          end

          private

          def read_devices_file
            Rails.root.join(ROOT_DIR, DEVICES_FILENAME).read
          end
        end
      end
    end
  end
end
