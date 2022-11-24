# frozen_string_literal: true
module OrdKit
  module Exporter
    module Samples
      class Base < OrdKit::Exporter::Base
        def to_ord
          OrdKit::ReactionInput.new(
            components: components,
            crude_components: crude_components,
            # TODO: position is actually wrong. We should count only "ADD" and "TRANSFER" for addition_order.
            # However addition_order allows value collisions and missing positions as well, so we're fine for now.
            addition_order: model.position + 1, # ORD is 1-indexed.
            addition_device: addition_device,
            addition_duration: addition_duration,
            addition_pressure: addition_pressure,
            addition_speed: addition_speed,
            addition_temperature: addition_temperature,
            addition_time: addition_time,
            flow_rate: flow_rate
          )
        end

        private

        def components
          raise StandardError, "Don't call #to_ord on abstract OrdKit::Exporter::Base"
        end

        def crude_components
          nil # n/a. We mostly cope with components in ELN.
        end

        def addition_device
          nil # TODO: hardcoded nil. Shall we assign the extra equipment?
        end


        def addition_time
          OrdKit::Time.new(
            value: model.start_time.to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def addition_duration
          OrdKit::Time.new(
            value: model.duration.to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def addition_pressure
          nil # Override where applicable (i.e. Actions ADD)
        end

        def addition_speed
          nil # Override where applicable (i.e. Actions ADD)
        end

        def addition_temperature
          nil # Override where applicable (i.e. Actions ADD)
        end

        def flow_rate
          nil # Override where applicable (i.e. Actions ADD)
        end
      end
    end
  end
end

