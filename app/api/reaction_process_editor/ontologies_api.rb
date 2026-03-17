# frozen_string_literal: true

module ReactionProcessEditor
  class OntologiesAPI < Grape::API

    helpers StrongParamsHelpers

    # # rescue_from :all

    desc 'get Ontologies'
    get :ontologies do
      { ontologies: ReactionProcessEditor::Ontology.where.not(label: nil) }
      { ontologies: ReactionProcessEditor::Ontology.where(id: ["1fbee868-06d0-4981-bb21-494e6ec3f94f", "dc211332-c58b-46f8-8b93-f636d88ef265", "805912b7-3c00-4590-aa26-438b6d74c37f"]) }
      { ontologies: ReactionProcessEditor::Ontology.where(id: ["805912b7-3c00-4590-aa26-438b6d74c37f"]) }
    end

    params do
      requires :ontology, type: Hash do
        optional :id
        requires :active, type: Boolean
        requires :ontology_id
        requires :label
        optional :name
        optional :link
        requires :roles, type: Hash
        optional :solvents, type: Array
        optional :detectors, type: Array
        optional :stationary_phase, type: Array
      end
    end
    desc 'Create or Update an Ontology'
    post :ontologies do

      Rails.logger.info("POST ONTOLOGIES")
      Rails.logger.info(params)
      Rails.logger.info(permitted_params)
      # create or update ontology
      Usecases::ReactionProcessEditor::Ontology::CreateOrUpdate.execute!(ontology_params: permitted_params[:ontology])
    end
  end
end
