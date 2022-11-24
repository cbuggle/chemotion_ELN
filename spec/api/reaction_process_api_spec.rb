# frozen_string_literal: true

require 'rails_helper'
include RequestSpecHelper

describe Chemotion::ReactionProcessAPI do
  let(:json_response) { JSON.parse(response.body) }

  let!(:reaction) { create(:valid_reaction) }
  let!(:reaction_process) { create(:reaction_process, reaction: reaction) }
  let!(:reaction_process_step) { create(:reaction_process_step) }

  let!(:uninitialized_reaction) { create(:valid_reaction) }

  let!(:additive_brine) { create(:additive, sample_name: 'Brine') }
  let!(:vessel) { create(:vessel, details: 'A created Vessel') }
  let!(:vessel_2) { create(:vessel, details: 'Another Vessel', reaction_process: create(:reaction_process)) }

  let(:expected_procedure_hash) do
    { id: anything,
      # reaction_process_steps: [
      #   hash_including('reaction_process_id' => reaction_process.id.to_s,
      #     reaction_process_actions: [],
      #     'position' => 0)
      # ],
      vessels: array_including(
        hash_including('details' => 'A created Vessel'),
      ),
      user_vessels: array_including(
        hash_including('details' => 'A created Vessel'),
        hash_including('details' => 'Another Vessel'),
      ),

      additives: [hash_including('label' => 'Brine')] }.deep_stringify_keys
  end

  let(:created_process_step) { reaction_process.reaction_process_steps.order(created_at: :asc).last }

  describe 'POST /api/v1/reaction/:id/reaction_process' do
    subject do
      post("/api/v1/reactions/#{uninitialized_reaction.id}/reaction_process",
           headers: jwt_authorization_header(uninitialized_reaction.creator))
    end

    it 'creates reaction_process' do
      expect { subject }.to change { uninitialized_reaction.reload.reaction_process }.from(nil)
    end

    it 'delivers reaction_process' do
      subject
      expect(json_response['reaction_process']).to be_present
    end

    context 'with existing reaction_process' do
      it 'is kept' do
        expect { subject }.not_to change { reaction.reload.reaction_process }.from(reaction_process)
      end
    end

    context 'missing reaction id' do
      subject { post('/api/v1/reactions/0/reaction_process', headers: jwt_authorization_header(reaction.creator)) }

      it '-> 404' do
        subject
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET /api/v1/reaction_process' do
    before do
      get("/api/v1/reaction_process/#{reaction_process.id}", headers: jwt_authorization_header(reaction.creator))
    end

    it 'responds 200' do
      expect(response).to have_http_status :ok
    end

    it 'delivers reaction_process hash' do
      expect(json_response['reaction_process']).to include expected_procedure_hash
    end
  end

  describe 'POST /api/v1/reaction_process/:id/reaction_process_steps' do
    it 'responds 201' do
      post("/api/v1/reaction_process/#{reaction_process.id}/reaction_process_steps",
           headers: jwt_authorization_header(reaction.creator))
      expect(response).to have_http_status :created
    end

    it 'creates ReactionProcessStep' do
      expect do
        post("/api/v1/reaction_process/#{reaction_process.id}/reaction_process_steps",
             headers: jwt_authorization_header(reaction.creator))
      end.to(
        change(ReactionProcessStep, :count).from(1).to(2),
      )
      expect(created_process_step.position).to eq 1
    end
  end
end
