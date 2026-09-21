# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::OntologiesAPI, '.get /ontologies' do
  include RequestSpecHelper

  subject(:api_call) do
    get('/api/v1/reaction_process_editor/ontologies',
        headers: authorization_header)
  end

  let(:user) { create(:person) }
  let(:authorization_header) { authorized_header(user) }
  let(:later_ontology) { create(:ontology, ontology_id: 'CHMO:2', label: 'Later') }
  let(:earlier_ontology) { create(:ontology, ontology_id: 'CHMO:1', label: 'Earlier') }

  before do
    later_ontology
    earlier_ontology
  end

  it 'returns ontologies ordered by ontology_id' do
    api_call

    expect(parsed_json_response['ontologies'].pluck('id')).to eq([earlier_ontology.id, later_ontology.id])
  end

  it 'returns an empty device methods array when the ontology has no methods' do
    api_call

    ontology_json = parsed_json_response['ontologies'].find { |item| item['id'] == earlier_ontology.id }
    expect(ontology_json['device_methods']).to eq([])
  end

  context 'when the ontology has a device method' do
    let!(:device_method) do
      create(
        :ontology_device_method,
        ontology: later_ontology,
        label: 'HPLC',
        detectors: ['UV'],
        active: false,
      )
    end

    it 'returns the device method' do
      api_call

      ontology_json = parsed_json_response['ontologies'].find { |item| item['id'] == later_ontology.id }
      expect(ontology_json['device_methods'].pluck('id')).to eq([device_method.id])
    end

    it 'returns the device method attributes' do
      api_call

      ontology_json = parsed_json_response['ontologies'].find { |item| item['id'] == later_ontology.id }
      expect(ontology_json['device_methods'].first)
        .to include('label' => 'HPLC', 'detectors' => ['UV'], 'active' => false)
    end
  end
end
