# frozen_string_literal: true

module OrdKit
  module Exporter
    module Samples
      class FractionExporter
        def initialize(fraction)
          @fraction = fraction
        end

        def to_ord
          return unless fraction

          OrdKit::PoolingFraction.new(
            position: fraction.position,
            vials:  fraction.vials,
            parent_activity_id: fraction.reaction_process_activity_id,
            followup_activity_id: fraction.followup_activity_id
          )
        end

        private

        attr_reader :fraction
      end
    end
  end
end
