# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class PressureExporter < OrdKit::Exporter::Amounts::Base

        def to_ord
          return unless value
          # This models a flow rate and corrsponds to "AdditionSpeed.type=Flow_Rate",
          # which is a separate ORD message (sibling which I find weird).
          # Might change this when rewriting UI. cbuggle.
         OrdKit::Pressure.new(
            value: value.to_f / 1000,
            precision: 10, # TODO: Check .
            units: OrdKit::Pressure::PressureUnit::BAR
          )
        end
      end
    end
  end
end
