# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class AddSampleExporter < OrdKit::Exporter::Samples::Base
        private

        def components
          [
            OrdKit::Exporter::Compounds::AddCompoundExporter.new(
              model,
            ).to_ord,
          ]
        end

        def flow_rate
          return unless model.workup['add_sample_velocity_value']

          OrdKit::Exporter::Amounts::FlowRateExporter.new(
            value: model.workup['add_sample_velocity_value'],
            unit: model.workup['add_sample_velocity_unit'],
          ).to_ord
        end

        def addition_pressure
          return unless model.workup['add_sample_pressure_value']

          OrdKit::Exporter::Amounts::PressureExporter.new(
            value: model.workup['add_sample_pressure_value'],
            unit: model.workup['add_sample_pressure_unit'],
          ).to_ord
        end

        def addition_speed
          return unless model.workup['addition_speed_type']

          OrdKit::Exporter::Amounts::AdditionSpeedExporter.new(
            value: model.workup['addition_speed_type'],
          ).to_ord
        end

        def addition_temperature
          return unless model.workup['add_sample_temperature_value']

          OrdKit::Exporter::Amounts::TemperatureExporter.new(
            value: model.workup['add_sample_temperature_value'],
            unit: model.workup['add_sample_temperature_value_unit'],
          ).to_ord
        end
      end
    end
  end
end
