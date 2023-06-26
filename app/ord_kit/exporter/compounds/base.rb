# frozen_string_literal: true

module OrdKit
  module Exporter
    module Compounds
      class Base < OrdKit::Exporter::Base
        DEFAULT_REACTION_ROLE_TYPE = OrdKit::ReactionRole::ReactionRoleType::UNSPECIFIED

        REACTION_ROLE_TYPES = {
          UNSPECIFIED: OrdKit::ReactionRole::ReactionRoleType::UNSPECIFIED,
          REACTANT: OrdKit::ReactionRole::ReactionRoleType::REACTANT,
          REAGENT: OrdKit::ReactionRole::ReactionRoleType::REAGENT,
          SOLVENT: OrdKit::ReactionRole::ReactionRoleType::SOLVENT,
          CATALYST: OrdKit::ReactionRole::ReactionRoleType::CATALYST,
          WORKUP: OrdKit::ReactionRole::ReactionRoleType::WORKUP,
          INTERNAL_STANDARD: OrdKit::ReactionRole::ReactionRoleType::INTERNAL_STANDARD,
          AUTHENTIC_STANDARD: OrdKit::ReactionRole::ReactionRoleType::AUTHENTIC_STANDARD,
          PRODUCT: OrdKit::ReactionRole::ReactionRoleType::PRODUCT,
          SAMPLE: OrdKit::ReactionRole::ReactionRoleType::SAMPLE,
          DIVERSE_SOLVENT: OrdKit::ReactionRole::ReactionRoleType::DIVERSE_SOLVENT,
          ADDITIVE: OrdKit::ReactionRole::ReactionRoleType::ADDITIVE,
          MEDIUM: OrdKit::ReactionRole::ReactionRoleType::MEDIUM,
          INTERMEDIATE: OrdKit::ReactionRole::ReactionRoleType::INTERMEDIATE,
          CRUDE: OrdKit::ReactionRole::ReactionRoleType::CRUDE,
          MIXTURE: OrdKit::ReactionRole::ReactionRoleType::MIXTURE,
        }.stringify_keys.freeze

        # Works on ReactionProcessStepAction ("ADD")

        def to_ord(is_waterfree_solvent: false)
          OrdKit::Compound.new(
            identifiers: identifiers, #   repeated :identifiers, :message, 1, "ord.CompoundIdentifier"
            amount: amount, #   optional :amount, :message, 2, "ord.Amount"
            reaction_role: reaction_role, #   optional :reaction_role, :enum, 3, "ord.ReactionRole.ReactionRoleType"
            is_limiting: nil, #   proto3_optional :is_limiting, :bool, 4
            preparations: preparations, #   repeated :preparations, :message, 5, "ord.CompoundPreparation"
            source: compound_source, #   optional :source, :message, 6, "ord.Compound.Source"
            features: nil, #   map :features, :string, :message, 7, "ord.Data"
            analyses: nil, #   map :analyses, :string, :message, 8, "ord.Analysis",
            purity: purity,
            is_waterfree_solvent: is_waterfree_solvent
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
