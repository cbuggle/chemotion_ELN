# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::VesselTypeExporter do
  subject(:vessel_type_export) do
    described_class.new(build(:vessel_template, vessel_type: 'round bottom flask')).to_clap
  end

  it 'falls back for unknown vessel types' do
    expect(vessel_type_export).to eq(Clap::VesselTemplate::VesselType::UNSPECIFIED)
  end
end
