# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::Automation::OntologiesAPI, '.put /ontologies/:id/ontology_device_methods' do
  include RequestSpecHelper

  subject(:api_call) do
    put("/api/v1/reaction_process_editor/ontologies/#{ontology_id}/ontology_device_methods",
        headers: authorization_header,
        params: params.to_json)
  end

  let(:user) { create(:user, type: 'ReactionProcessEditor::ApiUser') }
  let(:authorization_header) { authorized_header(user) }
  let(:ontology) { create(:ontology) }
  let(:ontology_id) { ontology.id }
  let(:params) do
    {
      ontology_device_methods: [
        {
          label: 'HPLC',
          detectors: ['UV'],
          mobile_phase: ['CHMO:0001 ()'],
          stationary_phase: ['silica'],
          default_inject_volume: { value: '10', unit: 'MICROLITER' },
          description: 'Default HPLC method',
          steps: [{ duration: { value: 10, unit: 'MINUTE' } }],
          active: true,
        },
      ],
    }
  end

  it 'responds with no content' do
    api_call

    expect(response).to have_http_status(:no_content)
  end

  it 'creates ontology device methods' do
    expect { api_call }.to change(ReactionProcessEditor::OntologyDeviceMethod, :count).by(1)
  end

  it 'sets the method label' do
    api_call

    expect(ontology.device_methods.first.label).to eq('HPLC')
  end

  it 'sets the method detectors' do
    api_call

    expect(ontology.device_methods.first.detectors).to eq(['UV'])
  end

  it 'sets the method mobile phase' do
    api_call

    expect(ontology.device_methods.first.mobile_phase).to eq(['CHMO:0001 ()'])
  end

  it 'sets the method stationary phase' do
    api_call

    expect(ontology.device_methods.first.stationary_phase).to eq(['silica'])
  end

  it 'sets the method default inject volume' do
    api_call

    expect(ontology.device_methods.first.default_inject_volume)
      .to eq('value' => '10', 'unit' => 'MICROLITER')
  end

  it 'sets the method description' do
    api_call

    expect(ontology.device_methods.first.description).to eq('Default HPLC method')
  end

  it 'sets the method steps' do
    api_call

    expect(ontology.device_methods.first.steps)
      .to eq([{ 'duration' => { 'value' => 10, 'unit' => 'MINUTE' } }])
  end

  it 'sets the method active flag' do
    api_call

    expect(ontology.device_methods.first.active).to be(true)
  end

  context 'with an SFC method and detector analysis defaults' do
    let(:params) do
      {
        ontology_device_methods: [
          {
            label: 'CO2-iPrOH_Iso-10-30min',
            detectors: [
              {
                label: 'PDA', value: 'CHMO:0001728',
                analysis_defaults: [
                  {
                    values: {
                      peaks: %w[210 230 256 280 366 400 450].map { |value| { unit: 'NM', value: value } },
                    },
                  },
                ],
              },
              {
                label: 'ELSD', value: 'CHMO:0002866',
                analysis_defaults: [
                  {
                    values: { unit: 'CELSIUS', value: '30' },
                  },
                ],
              },
              {
                label: 'MS', value: 'CHMO:0002337',
                analysis_defaults: [
                  {
                    values: '1000,700 V',
                  },
                ],
              },
            ],
            mobile_phase: ['CHEBI:17824 ()', 'CHEBI:38472 ()', 'CHEBI:17790 (0,1% CHEBI:30751)'],
            stationary_phase: ['VDSpher 100 Diol, OH 10um 250x50mm'],
            default_inject_volume: { unit: 'ml', value: 20 },
            description: 'SFC with 10% iPrOH modifier, 30min Isocratic separ...',
            steps: [],
            active: false,
          },
        ],
      }
    end

    it 'accepts the method' do
      api_call

      expect(response).to have_http_status(:no_content)
    end

    it 'stores the label' do
      api_call

      expect(ontology.device_methods.first.label).to eq('CO2-iPrOH_Iso-10-30min')
    end

    it 'stores the detector analysis defaults' do
      api_call

      expect(ontology.device_methods.first.detectors).to eq(params[:ontology_device_methods].first[:detectors].as_json)
    end

    it 'stores the mobile phase' do
      api_call

      expect(ontology.device_methods.first.mobile_phase)
        .to eq(['CHEBI:17824 ()', 'CHEBI:38472 ()', 'CHEBI:17790 (0,1% CHEBI:30751)'])
    end

    it 'stores the stationary phase' do
      api_call

      expect(ontology.device_methods.first.stationary_phase).to eq(['VDSpher 100 Diol, OH 10um 250x50mm'])
    end

    it 'stores the default inject volume' do
      api_call

      expect(ontology.device_methods.first.default_inject_volume).to eq('unit' => 'ml', 'value' => 20)
    end

    it 'stores the description' do
      api_call

      expect(ontology.device_methods.first.description)
        .to eq('SFC with 10% iPrOH modifier, 30min Isocratic separ...')
    end

    it 'stores an empty step list' do
      api_call

      expect(ontology.device_methods.first.steps).to eq([])
    end

    it 'stores the inactive flag' do
      api_call

      expect(ontology.device_methods.first.active).to be(false)
    end
  end

  context 'with an existing method id' do
    let!(:method) { create(:ontology_device_method, ontology: ontology, label: 'Old HPLC') }
    let(:params) do
      {
        ontology_device_methods: [
          {
            id: method.id,
            label: 'Updated HPLC',
          },
        ],
      }
    end

    it 'does not create a method' do
      expect { api_call }.not_to change(ReactionProcessEditor::OntologyDeviceMethod, :count)
    end

    it 'updates the existing method' do
      api_call

      expect(method.reload.label).to eq('Updated HPLC')
    end
  end

  context 'with a method id from another ontology' do
    let(:other_ontology) { create(:ontology) }
    let(:other_method) { create(:ontology_device_method, ontology: other_ontology, label: 'Other HPLC') }
    let(:params) do
      {
        ontology_device_methods: [
          {
            id: other_method.id,
            label: 'Updated HPLC',
          },
        ],
      }
    end

    it 'responds with not found' do
      api_call

      expect(response).to have_http_status(:not_found)
    end

    it 'does not update the other method' do
      api_call

      expect(other_method.reload.label).to eq('Other HPLC')
    end
  end

  context 'with an omitted existing method' do
    let!(:method) { create(:ontology_device_method, ontology: ontology) }

    it 'keeps the method associated with the ontology' do
      api_call

      expect(method.reload.ontology).to eq(ontology)
    end

    it 'deactivates the method' do
      api_call

      expect(method.reload.active).to be(false)
    end
  end

  context 'with an empty method list' do
    let!(:methods) { create_list(:ontology_device_method, 2, ontology: ontology) }
    let(:params) { { ontology_device_methods: [] } }

    it 'keeps all methods associated with the ontology' do
      api_call

      expect(ontology.device_methods.reload.ids).to match_array(methods.map(&:id))
    end

    it 'deactivates all methods' do
      api_call

      expect(methods.map { |method| method.reload.active }).to all(be(false))
    end
  end

  context 'with an unknown ontology id' do
    let(:ontology_id) { SecureRandom.uuid }

    it 'responds with not found' do
      api_call

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'without ontology device methods' do
    let(:params) { {} }

    it 'responds with bad request' do
      api_call

      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'with a method without label' do
    let(:params) { { ontology_device_methods: [{ description: 'Missing label' }] } }

    it 'responds with bad request' do
      api_call

      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'with a blank method label' do
    let(:params) { { ontology_device_methods: [{ label: '' }] } }

    it 'responds with unprocessable entity' do
      api_call

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'with duplicate method labels' do
    let!(:method) { create(:ontology_device_method, ontology: ontology, label: 'Existing HPLC') }
    let(:params) do
      {
        ontology_device_methods: [
          { id: method.id, label: 'Updated HPLC' },
          { label: 'Updated HPLC' },
        ],
      }
    end

    it 'responds with unprocessable entity' do
      api_call

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rolls back method updates' do
      api_call

      expect(method.reload.label).to eq('Existing HPLC')
    end
  end
end
