# frozen_string_literal: true

module OrdKit
  module Exporter
    module Compounds
      class TransferCompoundExporter < OrdKit::Exporter::Compounds::Base
        private

        def identifiers
          [OrdKit::CompoundIdentifier.new(
            type: OrdKit::CompoundIdentifier::IdentifierType::UNSPECIFIED, # TODO: hardcoded clarify
            details: details,
            value: value,
          )]
        end

        def details
          return unless model.has_sample?

          model.sample.preferred_label || model.sample.short_label
        end

        def value
          return unless model.has_sample?

          model.sample.name # TODO: inchi? iupac? smiles?
        end

        def reaction_role
          type = ReactionsSample.find_by(reaction: model.reaction, sample: model.sample)&.intermediate_type
          OrdKit::ReactionRole::ReactionRoleType.const_get type.to_s
        rescue NameError
          OrdKit::ReactionRole::ReactionRoleType::UNSPECIFIED
        end

        def amount
          Amount.new(
            percentage: Amounts::AmountExporter.new(
              value: (model.workup['transfer_percentage'] || 0) * 100,
            ).to_ord,
          )
        end

        def preparations
          [
            Preparations::CompoundPreparationsExporter.new(model).to_ord,
          ].compact
        end

        def compound_source
          OrdKit::Compound::Source.new(
            vendor: nil, # TODO: hardcoded empty. clarify.
            id: nil,
            lot: nil,
          )
        end
      end
    end
  end
end
