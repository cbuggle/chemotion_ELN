module OrdKit
  module Exporter
    module Conditions
      class Base
        def initialize(condition)
          @condition = condition
        end

        private

        attr_reader :condition
      end
    end
  end
end
