# frozen_string_literal: true

module OrdKit
  module Exporter
    module Amounts
      class Base
        def initialize(value:, unit: nil)
          @value = value
          @unit = unit
        end

        private

        attr_reader :value, :unit
      end
    end
  end
end
