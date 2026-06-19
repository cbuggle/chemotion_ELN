# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Metrics::FlowRateExporter do
  subject(:flow_rate) { described_class.new(workup).to_clap }

  context 'with a mapped flow rate unit' do
    let(:workup) { { 'value' => 1.5, 'unit' => 'MLMIN' } }

    it 'exports mapped flow rate units' do
      expect(flow_rate.to_h).to eq(value: 1.5, unit: :MILLILITER_PER_MINUTE)
    end
  end

  context 'with an unknown flow rate unit' do
    let(:workup) { { 'value' => 1.5, 'unit' => 'unknown' } }

    it 'falls back for unknown flow rate units' do
      expect(flow_rate.unit).to eq(:UNSPECIFIED)
    end
  end
end
