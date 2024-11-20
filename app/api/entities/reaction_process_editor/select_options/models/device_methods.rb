# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class DeviceMethods < Base
          DEVICENAME_PREFIX = ENV.fetch('REACTION_PROCESS_EDITOR_DEVICENAME_PREFIX', '')
          METHODNAME_SUFFIX = ENV.fetch('REACTION_PROCESS_EDITOR_DEVICE_METHODS_SUFFIX', '')

          REGEX_NAMES_AND_BRACKET_VALUES = /(.*?) \((.*?)\),?/.freeze

          def select_options_for(device_name:)
            Rails.logger.debug('DeviceMethoOptions')
            Rails.logger.debug(devices_methods_options(device_name: device_name))

            devices_methods_options(device_name: device_name) || []
          end

          private

          def devices_methods_options(device_name:)
            SelectOptions::Importer::DeviceMethods.new.csv_for_device(device_name: device_name).map do |method_csv|
              method_options(method_csv: method_csv, device_name: device_name)
            end
          end

          def method_options(method_csv:, device_name:)
            {
              label: method_label(method_csv: method_csv, device_name: device_name),
              value: method_label(method_csv: method_csv, device_name: device_name),
              detectors: SelectOptions::Models::MethodDetectors.new.to_options(method_csv['Detectors']),
              mobile_phases: mobile_phases_options(method_csv['Mobile Phase']),
              stationary_phases: [stationary_phase_option(method_csv['Stationary Phase'])],
              default_volume: { value: method_csv['Def. Inj. Vol.'], unit: 'ml' },
              description: method_csv['Description'],
              steps: steps(method_csv),
            }
          end

          def method_label(method_csv:, device_name:)
            method_csv['Method Name']
              .delete_prefix(DEVICENAME_PREFIX)
              .delete_prefix(device_name)
              .delete_prefix('_')
              .delete_suffix(METHODNAME_SUFFIX)
              .strip
          end

          def steps(method_csv)
            method_csv['Steps'] ? JSON.parse(method_csv['Steps']) : []
          rescue JSON::ParserError
            []
          end

          def mobile_phases_options(mobile_phases)
            mobile_phases.scan(REGEX_NAMES_AND_BRACKET_VALUES).map do |phase_match|
              options_for(phase_match[0])
            end.flatten
          end

          def stationary_phase_option(phase)
            phase_data = phase.match(REGEX_NAMES_AND_BRACKET_VALUES)

            label = phase_data[1].strip
            analysis_default_value = phase_data[2]

            option = { label: label, value: label }
            return option if analysis_default_value.blank?

            option.merge(stationary_phase_analysis_defaults(analysis_default_value))
          end

          def stationary_phase_analysis_defaults(value)
            { analysis_defaults: {
              TEMPERATURE: {
                value: value,
                unit: 'CELSIUS',
              },
            } }
          end
        end
      end
    end
  end
end
