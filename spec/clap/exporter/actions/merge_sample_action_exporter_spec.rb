# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::MergeSampleActionExporter do
  subject(:merge_sample_export) { described_class.new(action).to_clap(starts_at: 0).merge_samples }

  let(:source_sample) do
    create(:sample, name: 'Source sample', short_label: 'SRC-1', external_label: 'Source label', purity: 0.95)
  end
  let(:target_sample) do
    create(:sample, name: 'Target sample', short_label: 'TGT-1', external_label: 'Target label', purity: 0.8)
  end
  let(:action) do
    create(
      :reaction_process_activity,
      activity_name: 'MERGE_SAMPLES',
      workup: {
        source_sample_id: source_sample.id,
        target_sample_id: target_sample.id,
        amount: { value: '2', unit: 'g' },
      }.deep_stringify_keys,
    )
  end

  it 'exports the source sample label' do
    expect(merge_sample_export.source_sample.label).to eq(source_sample.preferred_label)
  end

  it 'exports the source sample reaction role' do
    expect(merge_sample_export.source_sample.reaction_role).to eq(:SAMPLE)
  end

  it 'exports the source sample name' do
    expect(merge_sample_export.source_sample.name).to eq('Source sample')
  end

  it 'exports the source sample purity' do
    expect(merge_sample_export.source_sample.purity.to_h).to eq(value: 95.0)
  end

  it 'exports the target sample label' do
    expect(merge_sample_export.target_sample.label).to eq(target_sample.preferred_label)
  end

  it 'exports the target sample reaction role' do
    expect(merge_sample_export.target_sample.reaction_role).to eq(:SAMPLE)
  end

  it 'exports the target sample name' do
    expect(merge_sample_export.target_sample.name).to eq('Target sample')
  end

  it 'exports the target sample purity' do
    expect(merge_sample_export.target_sample.purity.to_h).to eq(value: 80.0)
  end

  it 'exports the merged amount' do
    expect(merge_sample_export.amount.to_h).to eq(mass: { value: 2.0, unit: :GRAM })
  end

  context 'with a volume amount' do
    let(:action) do
      create(
        :reaction_process_activity,
        activity_name: 'MERGE_SAMPLES',
        workup: {
          source_sample_id: source_sample.id,
          target_sample_id: target_sample.id,
          amount: { value: '3', unit: 'ml' },
        }.deep_stringify_keys,
      )
    end

    it 'exports the merged volume amount' do
      expect(merge_sample_export.amount.to_h).to eq(volume: { value: 3.0, unit: :MILLILITER })
    end
  end

  context 'with a missing source sample' do
    let(:action) do
      create(
        :reaction_process_activity,
        activity_name: 'MERGE_SAMPLES',
        workup: {
          source_sample_id: 0,
          target_sample_id: target_sample.id,
          amount: { value: '2', unit: 'g' },
        }.deep_stringify_keys,
      )
    end

    it 'exports no source sample' do
      expect(merge_sample_export.source_sample).to be_nil
    end
  end

  context 'with a missing target sample' do
    let(:action) do
      create(
        :reaction_process_activity,
        activity_name: 'MERGE_SAMPLES',
        workup: {
          source_sample_id: source_sample.id,
          target_sample_id: 0,
          amount: { value: '2', unit: 'g' },
        }.deep_stringify_keys,
      )
    end

    it 'exports no target sample' do
      expect(merge_sample_export.target_sample).to be_nil
    end
  end
end
