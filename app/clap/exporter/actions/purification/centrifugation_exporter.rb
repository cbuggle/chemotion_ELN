# frozen_string_literal: true

module Clap
  module Exporter
    module Actions
      module Purification
        class CentrifugationExporter < Actions::Base
          private

          # rubocop:disable Layout/MultilineMethodCallIndentation
          def action_type_attributes
            {
              centrifugation: ReactionProcessAction::ActionCentrifugation
                             .new({ pressure: Metrics::PressureExporter.new(workup['PRESSURE']).to_clap,
                                    temperature: Metrics::TemperatureExporter.new(workup['TEMPERATURE']).to_clap,
                                    speed: Metrics::MotionExporter.new(workup['SPEED']).to_clap }),
            }
          end
          # rubocop:enable Layout/MultilineMethodCallIndentation
        end
      end
    end
  end
end
