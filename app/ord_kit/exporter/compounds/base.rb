# frozen_string_literal: true

module OrdKit
  module Exporter
    module Compounds
      class Base < OrdKit::Exporter::Base
        delegate :workup, to: :model

        def to_ord
          OrdKit::Compound.new(
            identifiers: identifiers,
            amount: amount,
            reaction_role: reaction_role,
            is_limiting: nil,
            preparations: preparations,
            source: compound_source,
            features: nil,
            analyses: nil,
            purity: purity,
            is_waterfree_solvent: workup['is_waterfree_solvent'],
          )
        end

        private

        def identifiers
          nil
        end

        def amount
          nil
        end

        def reaction_role
          nil
        end

        def preparations
          nil
        end

        def compound_source
          nil
        end

        def purity
          OrdKit::Percentage.new(
            value: (model.sample&.purity || 1) * 100,
          )
        end
      end
    end
  end
end
