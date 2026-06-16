# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::ReactionProcessStepAPI, '.put blank name' do
  include RequestSpecHelper

  subject(:api_call) do
    put("/api/v1/reaction_process_editor/reaction_process_steps/#{reaction_process_step.id}",
        params: { reaction_process_step: {
          name: '',
          reaction_process_vessel: reaction_process_vessel_params,
        } }.to_json,
        headers: authorization_header)
  end

  let(:reaction_process_step) { create(:reaction_process_step, position: 2) }
  let(:vessel) { create(:vessel) }
  let(:reaction_process_vessel_params) do
    { vesselable_id: vessel.id, vesselable_type: 'Vessel', preparations: ['DRIED'] }
  end
  let(:authorization_header) { authorized_header(reaction_process_step.creator) }

  it 'sets a default step name' do
    api_call
    expect(reaction_process_step.reload.name).to eq('Step 3')
  end
end
