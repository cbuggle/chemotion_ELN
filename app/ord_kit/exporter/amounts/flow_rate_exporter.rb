# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class FlowRateExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_FLOWRATE_UNIT = OrdKit::FlowRate::FlowRateUnit::MILLILITER_PER_MINUTE

        def to_ord
          return unless value

          # We have currently only "flow rate" so we deliver constants with no regard to the model / value
          # Flow Rate isin  a separate ORD message (sibling to AdditionSpeed which I find weird).
          # Might change this when rewriting UI. cbuggle.
          OrdKit::FlowRate.new(
            value: value.to_f,
            precision: nil,
            units: flow_rate_unit_for[unit] || ELN_DEFAULT_FLOWRATE_UNIT,
          )
        end

        private

        def flow_rate_unit_for
          { MLMIN: OrdKit::FlowRate::FlowRateUnit::MILLILITER_PER_MINUTE }
        end
      end
    end
  end
end
