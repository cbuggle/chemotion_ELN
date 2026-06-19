# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Vessels::VesselAttachmentsExporter do
  subject(:attachments) { described_class.new(build(:reaction_process_vessel)).to_clap }

  it 'exports no attachments until vessel attachments are implemented' do
    expect(attachments).to eq([])
  end
end
