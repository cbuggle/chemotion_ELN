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
          DEPENDENCY_FORMAT = /(.*?)\((.*?)\)\|?/.freeze

          TITLECASE_FIELDS = %w[label name].freeze

          HEADERS = { 'Custom Name': 'label',
                      'Ontology Name': 'name',
                      'Own Name': 'label',
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
                parent, dependencies = parent.split(PARENT_DEPENDENCIES_SEPARATOR)
                parent = parent.delete(PARENT_DELETE_CHARS).strip

                @ontologies[parent] ||= []
                @ontologies[parent] << csv_to_option(csv: csv)
                                       .merge({ dependencies: dependencies_option(dependencies) })
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

          def dependencies_option(dependencies)
            return unless dependencies

            option = {}
            dependencies.scan(DEPENDENCY_FORMAT).each do |chmo_id, dep_type|
              option[dep_type.strip] ||= []
              option[dep_type.strip] << chmo_id.tr('_', ':').strip
            end
            option
          end

          def ontologies_csv
            SelectOptions::Importer::Ontologies.new.read
          end
        end
      end
    end
  end
end
