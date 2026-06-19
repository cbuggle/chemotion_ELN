# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::ReactionProcessVesselableExporter do
  subject(:template_export) { described_class.new(reaction_process_vessel).to_clap }

  let(:vessel_template) { create(:vessel_template, vessel_type: 'VIAL', material_type: 'glass') }
  let(:reaction_process_vessel) { create(:reaction_process_vessel, vesselable: vessel_template) }

  it 'exports a vessel-template-backed template' do
    expect(template_export.vessel).to be_nil
  end

  context 'with a vessel-backed template' do
    let(:vessel) { create(:vessel, vessel_template: vessel_template, name: 'R1') }
    let(:reaction_process_vessel) do
      create(:reaction_process_vessel, vesselable: vessel, preparations: ['OVEN_DRIED'])
    end

    it 'exports the vessel-backed template' do
      expect(template_export.to_h).to include(
        id: vessel_template.id,
        name: vessel_template.name,
        type: :VIAL,
        material: 'GLASS',
        preparations: [{ type: :OVEN_DRIED }],
        vessel: hash_including(id: vessel.id),
      )
    end
  end

  context 'without a vesselable model' do
    let(:reaction_process_vessel) { nil }

    it 'returns nil' do
      expect(template_export).to be_nil
    end
  end
end
