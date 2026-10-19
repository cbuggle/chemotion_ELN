# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Metrics::PressureExporter do
  subject(:pressure_export) { described_class.new(workup).to_clap }

  context 'with a valid unit' do
    let(:workup) { { 'value' => 1013, 'unit' => 'MBAR' } }

    it 'exports pressure' do
      expect(pressure_export.to_h).to eq(value: 1013.0, unit: :MBAR)
    end
  end

  context 'without a unit' do
    let(:workup) { { 'value' => 1013, 'unit' => nil } }

    it 'uses the unspecified unit' do
      expect(pressure_export.unit).to eq(:UNSPECIFIED)
    end
  end

  context 'with an unknown unit' do
    let(:workup) { { 'value' => 1013, 'unit' => 'unknown' } }

    it 'uses the unspecified unit' do
      expect(pressure_export.unit).to eq(:UNSPECIFIED)
    end
  end
end
