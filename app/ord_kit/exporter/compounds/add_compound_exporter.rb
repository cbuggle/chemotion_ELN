# frozen_string_literal: true

module OrdKit
  module Exporter
    module Compounds
      class AddCompoundExporter < OrdKit::Exporter::Compounds::Base
        private

        def identifiers
          [OrdKit::CompoundIdentifier.new(
            type: OrdKit::CompoundIdentifier::IdentifierType::UNSPECIFIED, # TODO: hardcoded clarify
            details: details,
            value: value,
          )]
        end

        def details
          if model.has_sample?
            model.sample.name # TODO: inchi? iupac? smiles?
          elsif model.has_medium?
            model.medium.sample_name
          end
        end

        def value
          if model.has_sample?
            model.sample.preferred_label || model.sample.short_label
          elsif model.has_medium?
            model.medium.label
          end
        end

        def reaction_role
          OrdKit::ReactionRole::ReactionRoleType.const_get workup['acts_as']
        rescue NameError
          OrdKit::ReactionRole::ReactionRoleType::UNSPECIFIED
        end

        def amount
          Amounts::AmountExporter.new(
            value: workup['target_amount_value'],
            unit: workup['target_amount_unit'],
          ).to_ord
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
