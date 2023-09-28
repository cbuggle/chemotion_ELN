# frozen_string_literal: true

require 'rails_helper'
include RequestSpecHelper

describe Chemotion::ReactionProcessEditor::ReactionProcessStepAPI do
  let(:json_response) { JSON.parse(response.body) }

  let!(:reaction_process_step) { create(:reaction_process_step) }
  let!(:reaction) { reaction_process_step.reaction }

  let!(:vessel) { create(:vessel, name: 'A vessel', reaction_process_step: reaction_process_step) }

  describe 'GET /api/v1/reaction_process_step/:id' do
    subject do
      get("/api/v1/reaction_process_step/#{reaction_process_step.id}",
          headers: jwt_authorization_header(reaction.creator))
    end

    let(:expected_process_step_hash) do
      {
        reaction_process_id: anything,
        reaction_process_actions: [],
        vessel: hash_including('name' => 'A vessel'),
        materials_options: { 'ADDITIVE' => [], 'MEDIUM' => [], 'INTERMEDIATE' => [], 'SAMPLE' => [], 'SOLVENT' => [],
                           'DIVERSE_SOLVENT' => [] },
        added_materials_options: { 'ADDITIVE' => [], 'MEDIUM' => [], 'SOLVENT' => [], 'DIVERSE_SOLVENT' => [] },
        equipment_options: array_including(hash_including({ 'label' => 'Cannula', 'value' => 'CANNULA' })),
        mounted_equipment_options: [],
      }.deep_stringify_keys
    end

    it 'delivers reaction_process_step' do
      subject
      expect(json_response['reaction_process_step']).to include expected_process_step_hash
    end

    context 'with mounted equipment' do
      let(:expected_equipment_options) { [{ 'value' => 'STIRRER', 'label' => 'Stirrer' }] }

      before do
        create(:reaction_process_action_equip)
      end

      it 'delivers equipment' do
        pending "expected_equipment_options is now all of Ord constants. Don't know yet how to spec this best."
        expect(json_response['reaction_process_step']['equipment_options']).to include expected_equipment_options
      end

      it 'delivers mounted equipment' do
        subject
        expect(json_response['reaction_process_step']['mounted_equipment_options']).to eq expected_equipment_options
      end
    end

    describe 'DELETE /api/v1/reaction_process_step/:id' do
      subject do
        delete("/api/v1/reaction_process_step/#{reaction_process_step.id}",
               headers: jwt_authorization_header(reaction.creator))
      end

      it 'deletes' do
        subject
        expect(ReactionProcessStep.find_by(id: reaction_process_step.id)).to be_nil
      end
    end

    describe 'PUT /api/v1/reaction_process_step/:id' do
      let(:update_params) { { reaction_process_step: { name: 'New Name', locked: 'true' } } }
      let(:update_api) do
        proc {
          put("/api/v1/reaction_process_step/#{reaction_process_step.id}",
              headers: jwt_authorization_header(reaction.creator), params: update_params)
        }
      end

      it 'updates' do
        expect(reaction_process_step).not_to be_locked

        update_api.call
        expect(reaction_process_step.reload).to be_locked
        expect(reaction_process_step.reload.name).to eq 'New Name'

        # expect(json_response['reaction_process_step']['locked']).to be_truthy
      end
    end

    context 'with added samples' do
      let!(:sample) { create(:sample, reaction: reaction_process_step.reaction) }
      let(:expected_materials_options) do
        {
          'ADDITIVE' => [],
          'MEDIUM' => [],
          'SOLVENT' => [hash_including('label' => 'iupac_name')], # From factory `molecule`, somehow injected through factory `sample`
        }
      end

      before do
        create(:reaction_process_action_add, acts_as: 'SOLVENT', sample: sample)
        subject
      end

      it 'delivers sample_options' do
        pending "I failed to setup a sample that is properly associated with the reaction. Probably lacks some associated collection or something 'SOLVENT'=>'[]'" # cbuggle, 23.8.2021
        expect(json_response['reaction_process_step']['materials_options']).to include expected_materials_options
      end

      it 'delivers added sample_options' do
        expect(json_response['reaction_process_step']['added_materials_options']).to include expected_materials_options
      end
    end
  end

  describe 'POST /api/v1/reaction_process_step/:id/actions' do
    subject do
      post("/api/v1/reaction_process_step/#{reaction_process_step.id}/actions",
           params: create_action_params.to_json,
           headers: {
             'HTTP_ACCEPT' => 'application/json',
             'CONTENT_TYPE' => 'application/json',
           }.merge(jwt_authorization_header(reaction.creator)))
    end

    let!(:sample) { create(:sample, reaction: reaction_process_step.reaction) }
    let!(:create_action_params) do
      { action:
        { action_name: 'ADD',
          description: '',
          workup: {
            acts_as: 'SAMPLE',
            sample_id: sample.id.to_s,
          } } }
    end

    let!(:expected_create_action_hash) do
      { 'reaction_process_action' => hash_including({
                                                      'action_name' => 'ADD',
                                                      'workup' => hash_including({
                                                                                   'acts_as' => 'SAMPLE',
                                                                                   'description' => 'SAMPLE   iupac_name',
                                                                                   'sample_id' => sample.id.to_s,
                                                                                 }),
                                                    }) }
    end

    it 'creates action' do
      expect { subject }.to change { reaction_process_step.reaction_process_actions.count }.from(0).to(1)
    end

    it 'delivers reaction_process_action' do
      subject
      expect(json_response).to include(expected_create_action_hash)
    end

    it 'triggers set_initial_description' do
      expect_any_instance_of(ReactionProcessAction).to receive(:set_initial_description)
      subject
    end
  end

  describe 'PUT /api/v1/reaction_process_step/:id/vessel' do
    let!(:another_vessel) { create(:vessel) }

    let!(:set_vessel_params) { { vessel: { id: another_vessel.id.to_s } } }
    let!(:empty_vessel_params) { { vessel: nil } }

    it 'sets vessel' do
      expect do
        put("/api/v1/reaction_process_step/#{reaction_process_step.id}/vessel",
            params: set_vessel_params.to_json,
            headers: {
              'HTTP_ACCEPT' => 'application/json',
              'CONTENT_TYPE' => 'application/json',
            }.merge(jwt_authorization_header(reaction.creator)))
      end.to change { reaction_process_step.reload.vessel }.from(vessel).to(another_vessel)
    end

    it 'removes vessel' do
      expect do
        put("/api/v1/reaction_process_step/#{reaction_process_step.id}/vessel",
            params: empty_vessel_params.to_json,
            headers: {
              'HTTP_ACCEPT' => 'application/json',
              'CONTENT_TYPE' => 'application/json',
            }.merge(jwt_authorization_header(reaction.creator)))
      end.to change { reaction_process_step.reload.vessel }.from(vessel).to(nil)
    end
  end
end
