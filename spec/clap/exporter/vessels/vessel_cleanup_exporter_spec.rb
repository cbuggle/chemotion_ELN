# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::VesselCleanupExporter do
  subject(:cleanup_export) { described_class.new(build(:reaction_process_vessel, cleanup: 'WASTE')).to_clap }

  it 'exports cleanup type' do
    expect(cleanup_export.type).to eq(:WASTE)
  end
end
