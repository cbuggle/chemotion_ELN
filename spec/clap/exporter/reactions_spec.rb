# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap reaction exporters' do
  describe Clap::Exporter::Reactions::ReactionProvenanceExporter do
    let(:provenance) { create(:provenance, starts_at: '2026-06-17 08:00:00 UTC') }
    let(:clap) { described_class.new(provenance).to_clap }

    it 'exports provenance fields' do
      expect(clap.to_h).to include(
        city: 'Karlsruhe',
        doi: '10.1109/5.771073',
        patent: 'Creative Commons',
        publication_url: 'https://github.com/comPlat/chemotion_ELN',
        experimenter: hash_including(username: 'User1 Complat', email: 'complat.user1@eln.edu'),
        experiment_start: { value: '2026-06-17T08:00:00Z' },
      )
    end

    it 'returns nil without provenance' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Reactions::SampleSetupExporter do
    let(:sample_process) { create(:sample_process) }
    let(:reaction_process_vessel) do
      create(:reaction_process_vessel, reaction_process: sample_process)
    end
    let(:setup) { described_class.new(sample_process).to_clap }

    before do
      sample_process.update!(reaction_process_vessel: reaction_process_vessel)
    end

    it 'exports sample setup for a sample process' do
      expect(setup.vessel_template.id).to eq(sample_process.reaction_process_vessel.vesselable.vessel_template.id)
    end

    it 'returns nil without a sample' do
      expect(described_class.new(create(:reaction_process)).to_clap).to be_nil
    end
  end
end
