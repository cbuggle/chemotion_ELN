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
            ).to_ord(
              is_waterfree_solvent: model.workup['is_waterfree_solvent'],
            ),
          ]
        end

        def flow_rate
          return unless model.workup['add_sample_velocity']

          OrdKit::Exporter::Amounts::FlowRateExporter.new(value: model.workup['add_sample_velocity']).to_ord
        end

        def addition_pressure
          OrdKit::Exporter::Amounts::PressureExporter.new(value: model.workup['pressure_value']).to_ord
        end

        def addition_speed
          OrdKit::Exporter::Amounts::AdditionSpeedExporter.new(value: model.workup['add_sample_velocity']).to_ord
        end

        def addition_temperature
          OrdKit::Exporter::Amounts::TemperatureExporter.new(
            value: model.workup['temperature_value'],
            unit: model.workup['temperature_value_unit'],
          ).to_ord
        end
      end
    end
  end
end
