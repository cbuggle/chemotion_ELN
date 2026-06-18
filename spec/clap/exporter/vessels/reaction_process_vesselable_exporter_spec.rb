# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::ReactionProcessVesselableExporter do
  let(:vessel_template) { create(:vessel_template) }
  let(:reaction_process_vessel) { create(:reaction_process_vessel, vesselable: vessel_template) }
  let(:template) { described_class.new(reaction_process_vessel).to_clap }

  it 'exports a vessel-template-backed template' do
    expect(template.vessel).to be_nil
  end
end
