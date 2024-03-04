# frozen_string_literal: true

require 'rails_helper'

describe ReactionProcessEditor::ReactionProcessStepAPI, '.put' do
  include RequestSpecHelper

  subject(:api_call) do
    put("/api/v1/reaction_process_editor/reaction_process_steps/#{reaction_process_step.id}",
        params: { reaction_process_step: {
          name: 'New Step Name', vessel_id: vessel.id, locked: true,
          reaction_process_vessel: reaction_process_vessel_params
        } }.to_json,
        headers: authorization_header)
  end

  let!(:vessel) { create(:vessel) }
  let!(:reaction_process) { create_default(:reaction_process) }
  let!(:reaction_process_step) { create(:reaction_process_step, vessel: vessel) }
  let(:authorization_header) { authorized_header(reaction_process_step.creator) }
  let!(:reaction_process_vessel_params) { { preparations: ['DRIED'] } }

  it_behaves_like 'authorization restricted API call'

  it 'updates process_step' do
    expect do
      api_call
    end.to change { reaction_process_step.reload.name }.to('New Step Name')
  end

  it 'updates lock' do
    expect do
      api_call
    end.to change { reaction_process_step.reload.locked }.from(nil).to(true)
  end

  it 'triggers UseCase ReactionProcessVessels::Calculate' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessVessels::Calculate).to receive(:execute!)

    api_call

    expect(Usecases::ReactionProcessEditor::ReactionProcessVessels::Calculate).to have_received(:execute!).with(
      reaction_process_id: reaction_process.id,
    )
  end

  it 'triggers UseCase ReactionProcessVessels::CreateOrUpdate' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessVessels::CreateOrUpdate).to receive(:execute!)

    api_call

    expect(Usecases::ReactionProcessEditor::ReactionProcessVessels::CreateOrUpdate).to have_received(:execute!).with(
      reaction_process_id: reaction_process.id,
      vessel_id: vessel.id,
      reaction_process_vessel_params: reaction_process_vessel_params,
    )
  end

  describe 'assign vessel' do
    it 'creates ReactionProcessVessel' do
      expect do
        api_call
      end.to change {
               ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process: reaction_process)
             }.from(nil)
    end
  end

  context 'when vessel used in a different step' do
    before do
      create(:reaction_process_step, vessel: vessel)
      create(:reaction_process_vessel, reaction_process: reaction_process, vessel: vessel)
    end

    it 'retains ReactionProcessVessel' do
      expect do
        api_call
      end.not_to change(ReactionProcessEditor::ReactionProcessVessel, :count)
    end
  end
end
