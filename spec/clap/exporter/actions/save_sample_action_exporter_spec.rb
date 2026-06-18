# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::SaveSampleActionExporter do
  subject(:save_sample) { described_class.new(action).to_clap(starts_at: 0).save_sample }

  let(:action) do
    create(
      :reaction_process_activity_save,
      workup: {
        acts_as: 'SAMPLE',
        target_amount: { value: '2', unit: 'mg' },
        sample_origin_type: 'SPLIT',
        molecular_entities: [{ label: 'entity' }],
      },
    )
  end

  it 'exports saved sample' do
    expect(save_sample.to_h).to include(
      sample_origin_type: :SPLIT,
      molecular_entities: [{ label: 'entity' }],
    )
  end

  context 'with empty origin type' do
    let(:action) do
      create(:reaction_process_activity_save, workup: { acts_as: 'SAMPLE', sample_origin_type: nil })
    end

    it 'falls back for unknown sample origin types' do
      expect(save_sample.sample_origin_type).to eq(:UNSPECIFIED)
    end
  end
end
