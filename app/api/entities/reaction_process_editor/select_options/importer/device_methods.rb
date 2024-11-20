# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Importer
        class DeviceMethods
          DATA_DIR = ENV.fetch('REACTION_PROCESS_EDITOR_DATA_DIR', nil)
          DEVICES_FILES = '*.csv'
          DEVICENAME_PREFIX = ENV.fetch('REACTION_PROCESS_EDITOR_DEVICENAME_PREFIX', '')

          def by_devices
            all_with_device_name
          end

          def csv_for_device(device_name:)
            return [] if sanitize_device_name(device_name).blank?

            all_with_device_name[sanitize_device_name(device_name)] || []
          end

          private

          def all_with_device_name
            return @all_with_device_name if @all_with_device_name

            @all_with_device_name = {}

            device_methods_files.each do |filename|
              @all_with_device_name[parse_device_name(filename)] = read_csv(filename)
            end
            @all_with_device_name
          end

          def read_csv_with_device_name(filename)
            read_csv(filename).map { |csv| csv << { 'Device Name': parse_device_name(filename) }.stringify_keys }
          end

          def parse_device_name(filename)
            sanitize_device_name(File.basename(filename, '.csv'))
          end

          def sanitize_device_name(name)
            return unless name

            name.delete_prefix(DEVICENAME_PREFIX).delete('/-_').upcase
          end

          def read_csv(filename)
            CSV.parse(filename.read, col_sep: ';', headers: true, return_headers: false)
          end

          def device_methods_files
            Rails.logger.debug('READING DEVICE FILES')

            Rails.root.glob("#{DATA_DIR}/devices/#{DEVICES_FILES}")
          end
        end
      end
    end
  end
end
