# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap vessel exporters' do
  describe Clap::Exporter::Vessels::ReactionProcessVesselableExporter do
    let(:vessel_template) { create(:vessel_template, vessel_type: 'VIAL', material_type: 'glass') }
    let(:vessel) { create(:vessel, vessel_template: vessel_template, name: 'R1') }
    let(:reaction_process_vessel) do
      create(:reaction_process_vessel, vesselable: vessel, preparations: ['OVEN_DRIED'])
    end
    let(:template) { described_class.new(reaction_process_vessel).to_clap }

    it 'exports a vessel-backed template' do
      expect(template.to_h).to include(
        id: vessel_template.id,
        name: vessel_template.name,
        type: :VIAL,
        material: 'GLASS',
        preparations: [{ type: :OVEN_DRIED }],
        vessel: hash_including(id: vessel.id),
      )
    end

    it 'returns nil without a vesselable model' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Vessels::VesselAttachmentsExporter do
    it 'exports no attachments until vessel attachments are implemented' do
      expect(described_class.new(build(:reaction_process_vessel)).to_clap).to eq([])
    end
  end

  describe Clap::Exporter::Vessels::VesselCleanupExporter do
    let(:cleanup) { described_class.new(build(:reaction_process_vessel, cleanup: 'WASTE')).to_clap }

    it 'exports cleanup type' do
      expect(cleanup.type).to eq(:WASTE)
    end
  end

  describe Clap::Exporter::Vessels::VesselTypeExporter do
    it 'falls back for unknown vessel types' do
      expect(described_class.new(build(:vessel_template, vessel_type: 'round bottom flask')).to_clap).to eq(
        Clap::VesselTemplate::VesselType::UNSPECIFIED,
      )
    end
  end
end
