# frozen_string_literal: true

require 'rails_helper'
include RequestSpecHelper

describe Chemotion::VesselAPI do
  let(:json_response) { JSON.parse(response.body) }

  let!(:reaction) { create(:valid_reaction) }
  let!(:reaction_process) { create(:reaction_process, reaction: reaction) }
  let!(:reaction_process_step) { create(:reaction_process_step) }

  let!(:uninitialized_reaction) { create(:valid_reaction) }

  let!(:vessel) { create(:vessel, details: 'A created Vessel', reaction_process: reaction_process) }

  let(:expected_vessels_hash) do
    { 'automation_type' => 'AUTOMATED_TRUE',
      'details' => nil,
      'environment_details' => nil,
      'environment_type' => 'FUME_HOOD',
      'material_details' => nil,
      'material_type' => 'GLASS',
      'name' => nil,
      'preparations' => nil,
      'vessel_type' => 'ROUND_BOTTOM_FLASK',
      'volume_amount' => '500',
      'volume_unit' => 'MILLILITER' }
  end

  describe 'GET /api/v1/vessels' do
    let!(:vessel) { create(:vessel, reaction_process: reaction_process) }

    before { get('/api/v1/vessels', headers: jwt_authorization_header(reaction.creator)) }

    it 'reponds 200' do
      expect(response).to have_http_status :ok
    end

    it 'delivers vessels' do
      expect(json_response['vessels'].first).to include(expected_vessels_hash)
    end
  end

  describe 'POST /api/v1/vessels' do
    subject do
      post('/api/v1/vessels', params: { vessel: vessel.attributes }.merge(format: :json),
                              headers: jwt_authorization_header(reaction.creator))
    end

    let(:created_vessel) { Vessel.order('created_at').last }

    it 'responds 201' do
      subject
      expect(response).to have_http_status :created
    end

    it 'creates vessel' do
      expect { subject }.to change(Vessel, :count).by(1)
    end

    it 'creates user vessel' do
      expect { subject }.to change { reaction.creator.reload.vessels.count }.by(1)
    end

    it 'omits reaction_process vessel' do
      expect { subject }.not_to change { reaction_process.reload.vessels.count }
    end

    it 'assigns current user' do
      subject
      expect(created_vessel.user).to eq reaction_process.creator
    end

    it 'delivers vessels' do
      subject
      expect(json_response['vessel']).to include(expected_vessels_hash.merge({ details: 'A created Vessel' }).stringify_keys)
    end

    context 'param :assign_to_reaction' do
      subject do
        post('/api/v1/vessels', params: {
          vessel: vessel.attributes,
        }.merge({ format: :json, assign_to_reaction: true, reaction_process_id: reaction_process.id }), headers: jwt_authorization_header(reaction.creator))
      end

      it 'creates reaction_process vessel' do
        expect { subject }.to change { reaction_process.reload.vessels.count }.by(1)
      end
    end
  end

  describe 'PUT /api/v1/vessels/:id' do
    let(:update_vessel_attributes) { { id: vessel.id, volume_amount: '100', material_type: 'METAL' }.stringify_keys }

    before do
      put("/api/v1/vessels/#{vessel.id}", params: { vessel: update_vessel_attributes }.merge(format: :json),
                                          headers: jwt_authorization_header(reaction.creator))
    end

    it 'reponds 200' do
      expect(response).to have_http_status :ok
    end

    it 'delivers vessels' do
      expect(json_response['vessel']).to include(update_vessel_attributes)
    end
  end

  describe 'DELETE /api/v1/vessels/:id' do
    let!(:assigned_reaction_process_step) { create(:reaction_process_step, reaction_process: reaction_process) }

    before do
      assigned_reaction_process_step.set_vessel(vessel)
    end

    it 'deletes vessel' do
      expect do
        delete("/api/v1/vessels/#{vessel.id}",
               headers: {
                 'HTTP_ACCEPT' => 'application/json',
                 'CONTENT_TYPE' => 'application/json',
               }.merge(jwt_authorization_header(reaction.creator)))
      end.to change { Vessel.find_by(id: vessel.id) }.from(vessel).to(nil)
    end

    it 'unassigns vessel from process_steps' do
      expect do
        delete("/api/v1/vessels/#{vessel.id}",
               headers: {
                 'HTTP_ACCEPT' => 'application/json',
                 'CONTENT_TYPE' => 'application/json',
               }.merge(jwt_authorization_header(reaction.creator)))
      end.to change { assigned_reaction_process_step.reload.vessel }.from(vessel).to(nil)
    end
  end
end
