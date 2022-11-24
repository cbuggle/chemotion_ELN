# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class AdditionSpeedExporter < OrdKit::Exporter::Amounts::Base

        def to_ord
          return unless value
          # We have currently only "flow rate" so we deliver constants with no regard to the model / value
          # Flow Rate isin  a separate ORD message (sibling to AdditionSpeed which I find weird).
          # Might change this when rewriting UI. cbuggle.
          OrdKit::ReactionInput::AdditionSpeed.new(
            type:OrdKit::ReactionInput::AdditionSpeed::AdditionSpeedType::FLOW_RATE,
            details: ""
          )
        end
      end
    end
  end
end
