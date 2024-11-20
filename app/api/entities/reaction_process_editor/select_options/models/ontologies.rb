# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Ontologies < Base
          # File format constants as discussed and defined with PHodapp, NJung, cbuggle, 18.11.2024
          DEPENDENCY_SEPARATOR = '|'
          PARENT_SEPARATOR = ';'
          PARENT_DEPENDENCIES_SEPARATOR = ','
          PARENT_DELETE_CHARS = '=;'
          VALUES_WITH_BRACKET = /(.*?)\((.*?)\)\|?;?/.freeze

          TITLECASE_FIELDS = %w[label name].freeze

          HEADERS = { 'Custom Name': 'label',
                      'Ontology Name': 'name',
                      'Own Name': 'label', # files's csv headers are inconsistenly named
                      'Ontology ID': 'value',
                      'Full Link': 'link' }
                    .stringify_keys

          def all
            ontologies
          end

          private

          def ontologies
            @ontologies = {}
            ontologies_csv.filter_map do |csv|
              next if csv['Ontology ID'].blank?

              parents = csv['Parent']&.split(PARENT_SEPARATOR) || ['unused']

              parents.each do |parent|
                klass, dependencies = parent.split(PARENT_DEPENDENCIES_SEPARATOR)
                klass = klass.delete(PARENT_DELETE_CHARS).strip

                @ontologies[klass] ||= []
                @ontologies[klass] << csv_to_option(csv: csv)
                                      .merge(dependencies_options(dependencies))
                                      .merge(detector_options(csv['Detectors']))
                                      .merge(device_methods_options(csv['Custom Name'], klass))
              end
            end
            @ontologies
          end

          def needs_titlecase(key)
            TITLECASE_FIELDS.include?(key)
          end

          def csv_to_option(csv:)
            option = {}
            HEADERS.each do |csv_header, option_key|
              value = csv[csv_header]
              # value = value&.split('-')&.map(&:titlecase)&.join('-') if needs_titlecase(option_key)
              option[option_key] = value.strip if value.present?
            end
            option
          end

          def dependencies_options(dependencies)
            options = {}
            dependencies&.scan(VALUES_WITH_BRACKET)&.each do |chmo_id, dep_type|
              options[dep_type.strip] ||= []
              options[dep_type.strip] << chmo_id.tr('_', ':').strip
            end
            { dependencies: options }
          end

          def detector_options(detectors_csv)
            return {} if detectors_csv.blank?

            detectors = detectors_csv.scan(VALUES_WITH_BRACKET).map(&:first)

            { detectors: detectors }
          end

          def device_methods_options(device_name, klass)
            return {} if klass != 'device'

            Rails.logger.debug { "device_methods_options for #{device_name}" }
            # { device_methods: device_methods_instance.select_options_for(device_name: device_name) }

            { methods: device_methods_instance.select_options_for(device_name: device_name) }
          end

          def device_methods_instance
            @device_methods_instance ||= SelectOptions::Models::DeviceMethods.new
          end

          def ontologies_csv
            @ontologies_csv ||= SelectOptions::Importer::Ontologies.new.read
          end
        end
      end
    end
  end
end
