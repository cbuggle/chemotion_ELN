# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::VesselTypeExporter do
  subject(:vessel_type) { described_class.new(build(:vessel_template, vessel_type: 'round bottom flask')).to_clap }

  it 'falls back for unknown vessel types' do
    expect(vessel_type).to eq(Clap::VesselTemplate::VesselType::UNSPECIFIED)
  end
end
