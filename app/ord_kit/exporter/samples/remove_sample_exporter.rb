# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class RemoveSampleExporter < OrdKit::Exporter::Samples::Base
        def to_ord
          OrdKit::ReactionInput.new(
            components: components,
            crude_components: crude_components,
            addition_order: nil, # addition_order is pointless on REMOVE action.
            addition_time: addition_time,
            addition_speed: addition_speed,
            addition_duration: addition_duration,
            flow_rate: flow_rate,
            addition_device: addition_device,
            addition_temperature: addition_temperature,
          )
        end

        private

        def components
          [
            OrdKit::Exporter::Compounds::AddCompoundExporter.new(model).to_ord,
          ]
        end

        def addition_temperature
          OrdKit::Exporter::Amounts::TemperatureExporter.new(
            value: model.workup['remove_temperature'],
            unit: 'CELSIUS', # Currently we work only with Celsius
          ).to_ord
        end
      end
    end
  end
end
