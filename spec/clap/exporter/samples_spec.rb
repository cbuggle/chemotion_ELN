# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap sample exporters' do
  describe Clap::Exporter::Samples::FractionExporter do
    let(:fraction) { create(:fraction, vials: %w[A1 A2]) }

    it 'exports pooling fractions' do
      expect(described_class.new(fraction).to_clap.to_h).to include(position: 1, vials: %w[A1 A2])
    end

    it 'returns nil without a fraction' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Samples::SamplePreparationsExporter do
    let(:action) { create(:reaction_process_activity_add_sample) }
    let(:sample_preparation) do
      create(
        :samples_preparation,
        reaction_process: action.reaction_process,
        sample: action.sample,
        preparations: %w[DISSOLVED DRIED],
        equipment: %w[FUNNEL REACTOR],
      )
    end
    let(:preparation) do
      sample_preparation

      described_class.new(action).to_clap
    end

    it 'exports preparations for the action sample' do
      expect(preparation.to_h).to include(type: %i[DISSOLVED DRIED], equipment: [{ type: :FUNNEL }, { type: :REACTOR }])
    end
  end

  describe Clap::Exporter::Samples::SampleInActionExporter do
    let(:action) do
      create(
        :reaction_process_activity_add_sample,
        workup: {
          acts_as: 'SAMPLE',
          target_amount: { value: '12', unit: 'mg', percentage: 50 },
          is_waterfree_solvent: true,
        },
      )
    end
    let(:sample_preparation) do
      create(
        :samples_preparation,
        reaction_process: action.reaction_process,
        sample: action.sample,
        preparations: ['DRIED'],
      )
    end
    let(:sample) do
      sample_preparation

      described_class.new(action).to_clap
    end

    it 'exports an action sample' do
      expect(sample.to_h).to include(
        reaction_role: :SAMPLE,
        label: action.sample.preferred_label,
        amount: { mass: { value: 12.0, unit: :MILLIGRAM } },
        percentage: { value: 50.0 },
        purity: { value: 100.0 },
        is_waterfree_solvent: true,
      )
    end
  end

  describe Clap::Exporter::Samples::SolventsWithRatioExporter do
    let(:solvents) { described_class.new([{ 'id' => 'SOLVENT:1', 'label' => 'Water', 'ratio' => 2 }]).to_clap }

    before do
      ReactionProcessEditor::Ontology.create!(ontology_id: 'SOLVENT:1', label: 'Water', name: 'Water')
    end

    it 'exports solvent ratios with known ontologies' do
      expect(solvents.first.to_h).to eq(
        solvent: { label: 'Water', ontology: { id: 'SOLVENT:1', label: 'Water', name: 'Water' } },
        ratio: '2',
      )
    end
  end
end
