# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Models::StepAutomationControlExporter do
  it 'falls back for unknown step automation statuses' do
    expect(described_class.new({ 'status' => 'bad' }).to_clap[:step_status]).to eq(
      Clap::AutomationControl::StepAutomationStatus::STEP_AUTOMATION_STATUS_UNSPECIFIED,
    )
  end
end
