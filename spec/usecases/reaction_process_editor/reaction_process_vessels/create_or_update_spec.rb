# frozen_string_literal: true

RSpec.describe Usecases::ReactionProcessEditor::ReactionProcessVessels::CreateOrUpdate do
  subject(:create_or_update) do
    described_class.execute!(reaction_process_id: reaction_process.id,
                             vessel_id: vessel.id,
                             reaction_process_vessel_params: reaction_process_vessel_params)
  end

  let!(:reaction_process) { create_default(:reaction_process) }

  let(:reaction_process_vessel_params) { { preparations: ['DRIED'] } }
  let(:vessel) { create(:vessel) }

  before do
    create(:reaction_process_step, vessel: vessel)
  end

  it 'creates ReactionProcessVessel' do
    expect do
      create_or_update
    end.to change {
             ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                  vessel_id: vessel.id)
           }.from(nil)
  end

  it 'updates attributes' do
    expect do
      create_or_update
    end.to change {
             ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                  vessel_id: vessel.id)&.preparations
           }.to(['DRIED'])
  end

  it 'triggers ReactionProcesses::ReactionProcessVessels::Calculate' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessVessels::Calculate).to receive(:execute!)

    create_or_update

    expect(Usecases::ReactionProcessEditor::ReactionProcessVessels::Calculate).to have_received(:execute!).with(
      reaction_process_id: reaction_process.id,
    )
  end

  context 'with existing ReactionProcessVessel' do
    let!(:reaction_process_vessel) { create(:reaction_process_vessel, vessel: vessel) }

    it 'retains ReactionProcessVessel' do
      expect do
        create_or_update
      end.not_to(change do
                   ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                        vessel_id: vessel.id).id
                 end)
    end

    it 'updates attributes' do
      expect do
        create_or_update
      end.to change { reaction_process_vessel.reload.preparations }.to(['DRIED'])
    end
  end
end
