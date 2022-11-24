# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class AddSampleExporter < OrdKit::Exporter::Samples::Base
        private

        def components
          [
            OrdKit::Exporter::Compounds::AddCompoundExporter.new(
              model
            ).to_ord(
              is_waterfree_solvent: model.workup['is_waterfree_solvent']
            )
          ]
        end

        def flow_rate
          return unless model.workup['add_sample_speed_type'] == 'FLOW_RATE'

          OrdKit::ReactionInput::AdditionSpeed.new(
            type: ReactionInput::AdditionSpeed::AdditionSpeedType::FLOW_RATE, # only type in ELN.
            details: model.workup['add_sample_speed'],
          )
        end

        def addition_pressure
          OrdKit::Exporter::Amounts::PressureExporter.new(value: model.workup['pressure_value'] ).to_ord
        end

        def addition_speed
          OrdKit::Exporter::Amounts::AdditionSpeedExporter.new(value: model.workup['add_sample_speed']).to_ord
        end

        def addition_temperature
          OrdKit::Exporter::Amounts::TemperatureExporter.new(
            value: model.workup['temperature_value'],
            unit: model.workup['temperature_value_unit'],
          ).to_ord
        end

        def flow_rate
          nil # Override where applicable (i.e. Actions ADD)
        end
      end
    end
  end
end
