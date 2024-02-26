# frozen_string_literal: true

RSpec.describe Usecases::ReactionProcessEditor::ReactionProcesses::CalculateVessels do
  subject(:calculate_vessels) do
    described_class.execute!(reaction_process_id: reaction_process.id)
  end

  let!(:reaction_process) { create_default(:reaction_process) }

  let(:vessel) { create(:vessel) }
  let(:other_vessel) { create(:vessel) }
  let(:replaced_vessel) { create(:vessel) }

  before do
    create(:reaction_process_step, vessel: vessel)
    create(:reaction_process_step, vessel: other_vessel)
    create(:reaction_process_vessel, vessel: other_vessel)
    create(:reaction_process_vessel, vessel: replaced_vessel)
  end

  it 'creates ReactionProcessVessel' do
    expect do
      calculate_vessels
    end.to change {
             ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                  vessel_id: vessel.id)
           }.from(nil)
  end

  it 'retains other ReactionProcessVessel' do
    expect do
      calculate_vessels
    end.not_to(change do
                 ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                      vessel_id: other_vessel.id)
               end)
  end

  it 'destroys obsolete ReactionProcessVessel' do
    expect do
      calculate_vessels
    end.to change {
             ReactionProcessEditor::ReactionProcessVessel.find_by(reaction_process_id: reaction_process.id,
                                                                  vessel_id: replaced_vessel.id)
           }.to(nil)
  end

  context 'when vessel already used in another step' do
    before do
      create(:reaction_process_step, vessel: vessel)
      create(:reaction_process_vessel, vessel: vessel)
    end

    it 'retains ReactionProcessVessel' do
      expect do
        calculate_vessels
      end.not_to(change { ReactionProcessEditor::ReactionProcessVessel.find_by(vessel_id: vessel.id) })
    end
  end

  context 'when replaced vessel used in another step' do
    before do
      create(:reaction_process_step, vessel: replaced_vessel)
    end

    it 'retains ReactionProcessVessel' do
      expect do
        calculate_vessels
      end.not_to(change { ReactionProcessEditor::ReactionProcessVessel.find_by(vessel_id: replaced_vessel.id) })
    end
  end
end
