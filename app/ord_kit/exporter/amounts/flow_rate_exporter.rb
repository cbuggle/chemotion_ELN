# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class FlowRateExporter < OrdKit::Exporter::Amounts::Base
        ELN_DEFAULT_FLOWRATE_UNIT = 'MILLILITER_PER_MINUTE'

        def to_ord
          return unless value

          # We have currently only "flow rate" so we deliver constants with no regard to the model / value
          # Flow Rate isin  a separate ORD message (sibling to AdditionSpeed which I find weird).
          # Might change this when rewriting UI. cbuggle.
          OrdKit::FlowRate.new(
            value: value.to_f,
            precision: nil,
            units: OrdKit::FlowRate::FlowRateUnit.const_get(ELN_DEFAULT_FLOWRATE_UNIT),
          )
        end
      end
    end
  end
end
