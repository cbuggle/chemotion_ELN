# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::ReactionProcessAction do
  subject { build(:reaction_process_action) }

  it { is_expected.to belong_to(:reaction_process_step) }

  describe 'workup' do
    it 'ADD requires sample_id' do
      subject.action_name = 'ADD'
      expect(subject).to be_invalid
      subject.workup['sample_id'] = 'some database uuid'
      expect(subject).to be_valid
    end

    it 'REMOVE requires NO sample_id' do
      subject.action_name = 'REMOVE'
      expect(subject).to be_valid
      subject.workup['sample_id'] = 'some database uuid'
      expect(subject).to be_valid
    end

    it 'EQUIP requires equipment' do
      subject.action_name = 'EQUIP'
      expect(subject).to be_invalid
      subject.workup['equipment'] = 'SOME EQUIPMENT'
      expect(subject).to be_valid
    end
  end
end
