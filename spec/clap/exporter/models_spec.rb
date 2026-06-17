# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap model exporters' do
  describe Clap::Exporter::Models::AutomationControlExporter do
    it 'defaults missing automation control to can run' do
      expect(described_class.new(nil).to_clap).to eq(status: Clap::AutomationControl::AutomationStatus::CAN_RUN)
    end

    it 'exports dependency fields' do
      automation = described_class.new(
        {
          'status' => 'DEPENDS_ON_ACTION',
          'depends_on_action_id' => 'action-1',
          'depends_on_step_id' => 'step-1',
        },
      ).to_clap

      expect(automation).to eq(
        status: Clap::AutomationControl::AutomationStatus::DEPENDS_ON_ACTION,
        depends_on_action_id: 'action-1',
        depends_on_step_id: 'step-1',
      )
    end
  end

  describe Clap::Exporter::Models::StepAutomationControlExporter do
    it 'returns nil without step automation status' do
      expect(described_class.new({}).to_clap).to be_nil
    end

    it 'exports step automation status' do
      automation = described_class.new({ 'status' => 'STEP_COMPLETED' }).to_clap

      expect(automation).to eq(
        step_status: Clap::AutomationControl::StepAutomationStatus::STEP_COMPLETED,
        depends_on_action_id: nil,
        depends_on_step_id: nil,
      )
    end
  end

  describe Clap::Exporter::Models::OntologyExporter do
    it 'exports a known ontology' do
      ReactionProcessEditor::Ontology.create!(ontology_id: 'ONT:1', label: 'Label', name: 'Name')

      expect(described_class.new('ONT:1').to_clap).to eq(id: 'ONT:1', label: 'Label', name: 'Name')
    end

    it 'marks missing ontology values' do
      expect(described_class.new('missing').to_clap).to include(label: 'Error: Ontology specified but non-existant')
    end
  end
end
