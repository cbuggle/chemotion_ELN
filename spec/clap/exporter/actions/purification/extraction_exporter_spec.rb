# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::Purification::ExtractionExporter do
  subject(:extraction) { described_class.new(action).to_clap(starts_at: 0).extraction }

  let(:action) { create(:reaction_process_activity, activity_name: 'EXTRACTION', workup: { phase: 'bad' }) }

  it 'falls back for unknown extraction phases' do
    expect(extraction.phase).to eq(:UNSPECIFIED)
  end

  context 'with extraction steps' do
    let(:action) do
      create(
        :reaction_process_activity,
        activity_name: 'EXTRACTION',
        workup: {
          phase: 'ORGANIC',
          purification_steps: [{
            solvents: [{ label: 'solvent', ratio: 1 }],
            amount: { value: '1', unit: 'ml' },
            flow_rate: { value: '2', unit: 'MLMIN' },
            duration: 30_000,
          }],
        },
      )
    end

    it 'exports extraction steps' do
      expect(extraction.to_h).to include(
        phase: :ORGANIC,
        steps: [hash_including(duration: { value: 30.0, unit: :SECOND })],
      )
    end
  end
end
