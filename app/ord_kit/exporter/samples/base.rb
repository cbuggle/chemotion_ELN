# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class Base < OrdKit::Exporter::Base
        def to_ord
          OrdKit::ReactionInput.new(
            components: components,
            crude_components: crude_components,
            addition_order: addition_order,
            addition_device: addition_device,
            addition_duration: addition_duration,
            addition_speed: addition_speed,
            addition_time: addition_time,
            flow_rate: flow_rate,
            conditions: conditions,
          )
        end

        delegate :reaction_process, to: :model

        private

        def conditions
          OrdKit::Exporter::Conditions::ReactionConditionsExporter.new(model).to_ord
        end

        def components
          raise StandardError, "Don't call #to_ord on abstract OrdKit::Exporter::Base"
        end

        def crude_components
          nil # n/a. We mostly cope with components in ELN.
        end

        def addition_device
          nil
          # Concept incompatible to ELN. Hardcoded nil.
          # In ELN equipment is an array (not a single device)
          # and is stored with the action (not with the Compound added by the action)
        end

        def addition_time
          OrdKit::Time.new(
            value: 0, # TODO: redundant start_time has been removed, needs to be calculated.
            # model.start_time.to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def addition_duration
          OrdKit::Time.new(
            value: model.workup['duration'].to_i / 1000,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        # Override where applicable (i.e. Actions ADD)
        def addition_order; end
        def addition_pressure; end
        def addition_speed; end
        def addition_temperature; end
        def flow_rate; end
      end
    end
  end
end
