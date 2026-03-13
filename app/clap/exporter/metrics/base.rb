# frozen_string_literal: true

module Clap
  module Exporter
    module Metrics
      class Base
        def initialize(amount)
          Rails.logger.info("NEW METRICS EXPORTER")
          Rails.logger.info(amount)

          @amount = amount
          @value = @amount&.dig('value')
          @unit = @amount&.dig('unit').to_s
        end
      end
    end
  end
end
