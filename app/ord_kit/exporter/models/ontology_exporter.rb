# frozen_string_literal: true

module OrdKit
  module Exporter
    module Models
      class OntologyExporter
        def initialize(ontology_id)
          @ontology_id = ontology_id
        end

        def to_ord
          { id: @ontology_id,
            name: name(@ontology_id) }
        end

        private

        def name(ontology_id)
          ontology = ReactionProcessEditor::Ontology.find_by(ontology_id: ontology_id)

          ontology&.name || ontology_id || 'Export ERROR: Ontology without ontology_id'
        end
      end
    end
  end
end
