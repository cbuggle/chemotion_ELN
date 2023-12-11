# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::ReactionProcessAPI, '.post /reaction_process_steps' do
  include RequestSpecHelper
  subject(:api_call) do
    post("/api/v1/reaction_process_editor/reaction_processes/#{reaction_process.id}/reaction_process_steps",
         headers: authorization_header,
         params: { reaction_process_step: { name: 'New Step' } }.to_json)
  end

  let!(:reaction_process) { create_default(:reaction_process) }
  let(:expected_procedure_hash) do
    { id: anything }
    # reaction_process_steps: [
    #   hash_including('reaction_process_id' => reaction_process.id.to_s,
    #     reaction_process_activities: [],
    #     'position' => 0)
    # ],
  end

  let(:created_process_step) { reaction_process.reaction_process_steps.order(created_at: :asc).last }

  let(:authorization_header) { authorized_header(reaction_process.creator) }

  it_behaves_like 'authorization restricted API call'

  it 'responds 201' do
    api_call
    expect(response).to have_http_status :created
  end

  it 'returns created step' do
    api_call
    expect(parsed_json_response).to include(
      { reaction_process_step: hash_including({ name: 'New Step' }.deep_stringify_keys) }.deep_stringify_keys,
    )
  end

  it 'creates ReactionProcessStep' do
    expect do
      api_call
    end.to(
      change { reaction_process.reload.reaction_process_steps.length }.by(1),
    )
  end

  it 'sets position' do
    create(:reaction_process_step) # provides us with a more meaningful expectation "1".
    api_call
    expect(created_process_step.position).to eq 1
  end
end
