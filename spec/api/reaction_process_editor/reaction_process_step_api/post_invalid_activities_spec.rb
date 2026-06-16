# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::ReactionProcessStepAPI, '.post invalid /activities' do
  include RequestSpecHelper

  subject(:api_call) do
    post("/api/v1/reaction_process_editor/reaction_process_steps/#{reaction_process_step.id}/activities",
         params: { activity: { activity_name: 'ADD', workup: {} } }.to_json,
         headers: authorization_header)
  end

  let(:reaction_process_step) { create(:reaction_process_step) }
  let(:authorization_header) { authorized_header(reaction_process_step.creator) }

  it 'responds with unprocessable entity' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessSteps::AppendActivity).to receive(:execute!)
      .and_return(instance_double(ReactionProcessEditor::ReactionProcessActivity, valid?: false, errors: {}))

    api_call

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
