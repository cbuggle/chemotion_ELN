# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap metric exporters' do
  describe Clap::Exporter::Metrics::AmountExporter do
    let(:amount) { described_class.new(workup).to_clap }

    context 'with a volume amount' do
      let(:workup) { { 'value' => 2, 'unit' => 'ml' } }

      it 'exports volume amounts' do
        expect(amount.volume.to_h).to eq(value: 2.0, unit: :MILLILITER)
      end
    end

    context 'with a mass amount' do
      let(:workup) { { 'value' => 3, 'unit' => 'mg' } }

      it 'exports mass amounts' do
        expect(amount.mass.to_h).to eq(value: 3.0, unit: :MILLIGRAM)
      end
    end

    context 'with a moles amount' do
      let(:workup) { { 'value' => 4, 'unit' => 'mmol' } }

      it 'exports moles amounts' do
        expect(amount.moles.to_h).to eq(value: 4.0, unit: :MILLIMOLE)
      end
    end

    context 'with a percentage amount' do
      let(:workup) { { 'value' => 5, 'unit' => 'PERCENT' } }

      it 'exports percentage amounts' do
        expect(amount.percentage.to_h).to eq(value: 5.0)
      end
    end

    it 'returns nil when no amount is provided' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Metrics::FlowRateExporter do
    let(:flow_rate) { described_class.new(workup).to_clap }

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

  describe Clap::Exporter::Metrics::LengthExporter do
    let(:length) { described_class.new({ 'value' => 6, 'unit' => 'CM' }).to_clap }

    it 'exports mapped length units' do
      expect(length.to_h).to eq(value: 6.0, unit: :CENTIMETER)
    end
  end

  describe Clap::Exporter::Metrics::PressureExporter do
    let(:pressure) { described_class.new({ 'value' => 1013, 'unit' => 'MBAR' }).to_clap }

    it 'exports pressure' do
      expect(pressure.to_h).to eq(value: 1013.0, unit: :MBAR)
    end
  end

  describe Clap::Exporter::Metrics::TemperatureExporter do
    let(:temperature) { described_class.new({ 'value' => 21, 'unit' => 'CELSIUS' }).to_clap }

    it 'exports temperature' do
      expect(temperature.to_h).to eq(value: 21.0, unit: :CELSIUS)
    end
  end

  describe Clap::Exporter::Metrics::TimeSpanExporter do
    let(:duration) { described_class.new(90_000).to_clap }

    it 'exports milliseconds as seconds' do
      expect(duration.to_h).to eq(value: 90.0, unit: :SECOND)
    end
  end

  describe Clap::Exporter::Metrics::WavelengthRangeExporter do
    let(:range) do
      described_class.new(
        {
          'is_range' => true,
          'peaks' => [{ 'value' => 365, 'unit' => 'NM' }],
        },
      ).to_clap
    end

    it 'exports wavelength peaks' do
      expect(range.to_h).to eq(is_range: true, peaks: [{ value: 365.0, unit: :NANOMETER }])
    end
  end
end
