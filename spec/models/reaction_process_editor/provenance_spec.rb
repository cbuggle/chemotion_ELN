# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::Provenance do
  subject(:provenance) { described_class.new(reaction_process: create(:reaction_process)) }

  it { is_expected.to belong_to(:reaction_process) }

  describe '#initialize' do
    let(:starts_at) { '2026-06-16 11:22:33' }

    it 'sets starts_at rounded to the current minute' do
      travel_to Time.zone.local(2026, 6, 16, 12, 34, 56) do
        expect(provenance.starts_at).to eq(Time.zone.local(2026, 6, 16, 12, 34))
      end
    end

    it 'keeps provided starts_at' do
      expect(described_class.new(starts_at: starts_at).starts_at).to eq(Time.zone.parse(starts_at))
    end
  end

  describe '#starts_at=' do
    it 'parses string values' do
      provenance.starts_at = '2026-06-16 10:20:30'

      expect(provenance.starts_at).to eq(Time.zone.parse('2026-06-16 10:20:30'))
    end

    it 'falls back to now for invalid values' do
      travel_to Time.zone.local(2026, 6, 16, 12, 34, 56) do
        provenance.starts_at = nil

        expect(provenance.starts_at).to eq(Time.zone.local(2026, 6, 16, 12, 34, 56))
      end
    end
  end
end
