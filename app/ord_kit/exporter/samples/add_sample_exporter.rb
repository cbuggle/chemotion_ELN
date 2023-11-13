# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class AddSampleExporter < OrdKit::Exporter::Samples::Base
        private

        def components
          [
            OrdKit::Exporter::Compounds::AddCompoundExporter.new(action).to_ord,
          ]
        end

        def addition_order
          # ORD is 1-indexed.
          action.siblings.select(&:adds_sample?).index(action) + 1
        end

        def addition_temperature
          return unless action.workup['add_sample_temperature_value']

          OrdKit::Exporter::Metrics::TemperatureExporter.new(action.workup['add_sample_temperature']).to_ord
        end

        def addition_pressure
          return unless action.workup['add_sample_pressure']

          OrdKit::Exporter::Metrics::PressureExporter.new(action.workup['add_sample_pressure']).to_ord
        end

        def flow_rate
          return unless action.workup['add_sample_velocity']

          OrdKit::Exporter::Metrics::FlowRateExporter.new(action.workup['add_sample_velocity']).to_ord
        end

        def addition_speed_type
          return unless action.workup['addition_speed_type']

          OrdKit::Exporter::Metrics::AdditionSpeedTypeExporter.new(action.workup['addition_speed_type']).to_ord
        end
      end
    end
  end
end
