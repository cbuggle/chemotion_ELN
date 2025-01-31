# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Ontologies < Base
          def all
            ::ReactionProcessEditor::Ontology.includes([:device_methods]).order(:updated_at).map do |ontology|
              ontology.attributes
                      .slice(*%w[label ontology_id solvents link roles active])
                      .merge({
                               value: ontology.ontology_id,
                               inactive: !ontology.active,
                               methods: SelectOptions::Models::DeviceMethods.new.select_options_for(
                                 ontology.device_methods,
                               ),
                               detectors: SelectOptions::Models::Detectors.new.select_options_for(
                                 ontology.detectors,
                               ),
                               stationary_phase: stationary_phase_options(ontology),
                             })
            end
          end

          private

          def stationary_phase_options(ontology)
            ontology.stationary_phase.map do |stationary_phase|
              # The stationary_phases (which only exist for device ontologies) will be feed into a OntologySelectForm
              # for "stationary_phase" as preselection when the device is selected. Therefore it needs to resemble an
              # Ontology, i.e. be "active", have a proper ontology_id, and have their "role" defined
              # as "stationary_phase" with empty dependencies.

              ontology_field_option_for(base_ontology: ontology, role: 'stationary_phase', value: stationary_phase)
              # option_for(stationary_phase).merge(
              #   { active: ontology.active,
              #     ontology_id: stationary_phase,
              #     roles: { stationary_phase: [{}] } },
              # )
            end
          end
        end
      end
    end
  end
end
