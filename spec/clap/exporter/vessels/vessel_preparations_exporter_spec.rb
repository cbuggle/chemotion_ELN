# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::VesselPreparationsExporter do
  it 'falls back for unknown preparations' do
    expect(described_class.new(['bad']).to_clap.first.type).to eq(:UNSPECIFIED)
  end
end
