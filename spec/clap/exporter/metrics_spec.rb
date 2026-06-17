# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap metric exporters' do
  describe Clap::Exporter::Metrics::AmountExporter do
    it 'exports volume amounts' do
      amount = described_class.new({ 'value' => 2, 'unit' => 'ml' }).to_clap

      expect(amount.volume.to_h).to eq(value: 2.0, unit: :MILLILITER)
    end

    it 'exports mass amounts' do
      amount = described_class.new({ 'value' => 3, 'unit' => 'mg' }).to_clap

      expect(amount.mass.to_h).to eq(value: 3.0, unit: :MILLIGRAM)
    end

    it 'exports moles amounts' do
      amount = described_class.new({ 'value' => 4, 'unit' => 'mmol' }).to_clap

      expect(amount.moles.to_h).to eq(value: 4.0, unit: :MILLIMOLE)
    end

    it 'exports percentage amounts' do
      amount = described_class.new({ 'value' => 5, 'unit' => 'PERCENT' }).to_clap

      expect(amount.percentage.to_h).to eq(value: 5.0)
    end

    it 'returns nil when no amount is provided' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Metrics::FlowRateExporter do
    it 'exports mapped flow rate units' do
      flow_rate = described_class.new({ 'value' => 1.5, 'unit' => 'MLMIN' }).to_clap

      expect(flow_rate.to_h).to eq(value: 1.5, unit: :MILLILITER_PER_MINUTE)
    end

    it 'falls back for unknown flow rate units' do
      flow_rate = described_class.new({ 'value' => 1.5, 'unit' => 'unknown' }).to_clap

      expect(flow_rate.unit).to eq(:UNSPECIFIED)
    end
  end

  describe Clap::Exporter::Metrics::LengthExporter do
    it 'exports mapped length units' do
      length = described_class.new({ 'value' => 6, 'unit' => 'CM' }).to_clap

      expect(length.to_h).to eq(value: 6.0, unit: :CENTIMETER)
    end
  end

  describe Clap::Exporter::Metrics::PressureExporter do
    it 'exports pressure' do
      pressure = described_class.new({ 'value' => 1013, 'unit' => 'MBAR' }).to_clap

      expect(pressure.to_h).to eq(value: 1013.0, unit: :MBAR)
    end
  end

  describe Clap::Exporter::Metrics::TemperatureExporter do
    it 'exports temperature' do
      temperature = described_class.new({ 'value' => 21, 'unit' => 'CELSIUS' }).to_clap

      expect(temperature.to_h).to eq(value: 21.0, unit: :CELSIUS)
    end
  end

  describe Clap::Exporter::Metrics::TimeSpanExporter do
    it 'exports milliseconds as seconds' do
      duration = described_class.new(90_000).to_clap

      expect(duration.to_h).to eq(value: 90.0, unit: :SECOND)
    end
  end

  describe Clap::Exporter::Metrics::WavelengthRangeExporter do
    it 'exports wavelength peaks' do
      range = described_class.new(
        {
          'is_range' => true,
          'peaks' => [{ 'value' => 365, 'unit' => 'NM' }],
        },
      ).to_clap

      expect(range.to_h).to eq(is_range: true, peaks: [{ value: 365.0, unit: :NANOMETER }])
    end
  end
end
