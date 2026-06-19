# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Models::StepAutomationControlExporter do
  subject(:automation) { described_class.new(workup).to_clap }

  let(:workup) { { 'status' => 'bad' } }

  it 'falls back for unknown step automation statuses' do
    expect(automation[:step_status]).to eq(
      Clap::AutomationControl::StepAutomationStatus::STEP_AUTOMATION_STATUS_UNSPECIFIED,
    )
  end

  context 'without step automation status' do
    let(:workup) { {} }

    it 'returns nil' do
      expect(automation).to be_nil
    end
  end

  context 'with a completed step status' do
    let(:workup) { { 'status' => 'STEP_COMPLETED' } }

    it 'exports step automation status' do
      expect(automation).to eq(
        step_status: Clap::AutomationControl::StepAutomationStatus::STEP_COMPLETED,
        depends_on_action_id: nil,
        depends_on_step_id: nil,
      )
    end
  end
end
