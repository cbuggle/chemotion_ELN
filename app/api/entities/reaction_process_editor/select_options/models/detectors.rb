# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Detectors < Base
          DETECTOR_TYPES = { PDA: ['CHMO:0001728', 'WAVELENGTHLIST', 'WAVELENGTHS', 'NM', 'Wavelengths (nm)'],
                             ELSD: %w[CHMO:0001718 METRIC TEMPERATURE CELSIUS Temperature],
                             MS: %w[CHMO:0002337 TEXT MS_PARAMETER V Parameter],
                             #  MS: %w[CHMO:0002174 TEXT MS_PARAMETER V Parameter],
                             FID: %w[CHMO:0001719 METRIC WEIGTH g Weight],
                             BID: %w[CHMO:0001724 METRIC WEIGTH g Weight] }.stringify_keys

          REGEX_NAMES_AND_BRACKET_VALUES = /(.*?) \((.*?)\),*/.freeze

          def to_options(detectors_csv)
            detectors_data = detectors_csv.scan(REGEX_NAMES_AND_BRACKET_VALUES)
            detectors_data.map { |detector_csv| detector_options(detector_csv) }
          end

          private

          def detector_options(detector_csv)
            detector_name = detector_csv[0].strip
            analysis_default_values = detector_csv[1]

            options = { label: detector_name, value: chmo_id(detector_name), source: 'method_detectors.rb' }

            return options if analysis_default_values.blank?

            options.merge(analysis_defaults: detector_analysis_defaults(detector_name,
                                                                        analysis_default_values))
          end

          def chmo_id(detector_name)
            DETECTOR_TYPES[detector_name].first
          end

          def detector_analysis_defaults(detector_name, values)
            # TODO: this is almost identical to detector_options in Detectors (except values)
            chmo_id, data_type, metric, unit, label = DETECTOR_TYPES[detector_name]

            return [] unless chmo_id

            # TODO: A detector might have multiple metrics /metric_names (therefore we return an array).
            # Current files have only one. Adapt CSV parsing once File format has been defined. cbuggle, 14.10.2024.
            [{
              label: label,
              data_type: data_type,
              metric_name: metric,
              values: analysis_default_values(data_type: data_type, values: values, unit: unit),
            }]
          end

          def analysis_default_values(data_type:, values:, unit:)
            case data_type
            when 'TEXT'
              "#{values} #{unit}"
            when 'METRIC'
              { value: values, unit: unit }
            when 'WAVELENGTHLIST'
              { peaks: split_values(values: values, unit: unit) }
            end
          end

          def split_values(values:, unit:)
            values.split(',').map do |value|
              { value: value, unit: unit }
            end
          end
        end
      end
    end
  end
end
