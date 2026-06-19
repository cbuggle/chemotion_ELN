# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Reactions::SampleSetupExporter do
  subject(:setup_export) { described_class.new(reaction_process).to_clap }

  let(:reaction_process) { create(:sample_process) }
  let(:reaction_process_vessel) do
    create(:reaction_process_vessel, reaction_process: reaction_process)
  end

  before do
    reaction_process.update!(reaction_process_vessel: reaction_process_vessel)
  end

  it 'exports sample setup for a sample process' do
    expect(setup_export.vessel_template.id).to eq(
      reaction_process.reaction_process_vessel.vesselable.vessel_template.id,
    )
  end

  context 'without a sample process' do
    let(:reaction_process) { create(:reaction_process) }

    it 'returns nil' do
      expect(setup_export).to be_nil
    end
  end
end
