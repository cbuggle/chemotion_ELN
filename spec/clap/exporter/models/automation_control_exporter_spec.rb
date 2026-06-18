# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Models::AutomationControlExporter do
  it 'falls back for unknown automation statuses' do
    expect(described_class.new({ 'status' => 'bad' }).to_clap[:status]).to eq(
      Clap::AutomationControl::AutomationStatus::AUTOMATION_STATUS_UNSPECIFIED,
    )
  end
end
