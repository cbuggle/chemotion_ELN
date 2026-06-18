# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap metric exporter fallback units' do
  it 'falls back for unknown amount and metric units' do
    expect(
      [
        Clap::Exporter::Metrics::Amounts::MolesExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::Amounts::VolumeExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::MotionExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::PowerExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::TemperatureExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::WavelengthExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
        Clap::Exporter::Metrics::LengthExporter.new({ 'value' => 1, 'unit' => 'bad' }).to_clap.unit,
      ],
    ).to all(eq(:UNSPECIFIED))
  end
end
