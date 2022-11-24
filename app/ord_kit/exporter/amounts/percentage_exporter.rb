# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class PercentageExporter < OrdKit::Exporter::Amounts::Base
        def to_ord
          OrdKit::Percentage.new(
            value: value,
            precision: nil, # TODO: precision states the number of valid digits. 3 or something.
          )
        end
      end
    end
  end
end
