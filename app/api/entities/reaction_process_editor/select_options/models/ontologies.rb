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
                               is_new: ontology.detectors,
                             })
            end
          end
        end
      end
    end
  end
end
