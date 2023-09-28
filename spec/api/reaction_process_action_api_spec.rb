# frozen_string_literal: true

require 'rails_helper'
include RequestSpecHelper

describe Chemotion::ReactionProcessActionAPI do
  let(:json_response) { JSON.parse(response.body) }

  let!(:reaction_process_step) { create(:reaction_process_step) }
  let!(:reaction) { reaction_process_step.reaction }

  let(:action) { create(:reaction_process_action_add_solvent) }

  describe 'PUT /api/v1/action/:id/' do
    subject do
      put("/api/v1/reaction_process_action/#{action.id}",
          params: update_action_params.to_json,
          headers: {
            'HTTP_ACCEPT' => 'application/json',
            'CONTENT_TYPE' => 'application/json',
          }.merge(jwt_authorization_header(reaction.creator)))
    end

    let(:action) { create(:reaction_process_action_add_solvent) }
    let!(:sample) { create(:sample, reaction: reaction) }
    let(:update_action_params) do
      { action:
        { action_name: 'ADD',
          description: '',
          workup: {
            acts_as: 'SAMPLE',
            sample_id: sample.id.to_s,
            target_amount_value: '5',
            target_amount_unit: 'l',
          } } }
    end

    let(:expected_workup_hash) do
      {
        'acts_as' => 'SAMPLE',
        'sample_id' => sample.id.to_s,
        'target_amount_value' => '5',
        'target_amount_unit' => 'l',
      }
    end

    let(:expected_update_action_hash) do
      { 'reaction_process_action' => hash_including(
        {
          'action_name' => 'ADD',
          'workup' => hash_including(expected_workup_hash),
        },
      ) }
    end

    it 'updates action' do
      expect { subject }.to change {
        action.reload.workup
      }.from(
        hash_including({ 'acts_as' => 'SOLVENT', 'target_amount_value' => '500', 'target_amount_unit' => 'ml' }),
      ).to(
        expected_workup_hash,
      )
    end

    it 'delivers reaction_process_action' do
      subject
      expect(json_response).to include(expected_update_action_hash)
    end
  end

  describe 'DELETE /api/v1/action/:id' do
    subject do
      delete("/api/v1/reaction_process_action/#{action.id}", headers: jwt_authorization_header(reaction.creator))
    end

    it 'destroys action' do
      expect_any_instance_of(ReactionProcessAction).to receive(:delete_from_reaction_process_step).and_call_original
      subject
      expect(ReactionProcessAction.find_by(id: action.id)).to be_nil
    end
  end
end
