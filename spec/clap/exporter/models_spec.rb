# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap model exporters' do
  describe Clap::Exporter::Models::AutomationControlExporter do
    let(:automation) { described_class.new(workup).to_clap }

    it 'defaults missing automation control to can run' do
      expect(described_class.new(nil).to_clap).to eq(status: Clap::AutomationControl::AutomationStatus::CAN_RUN)
    end

    context 'with dependency fields' do
      let(:workup) do
        {
          'status' => 'DEPENDS_ON_ACTION',
          'depends_on_action_id' => 'action-1',
          'depends_on_step_id' => 'step-1',
        }
      end

      it 'exports dependency fields' do
        expect(automation).to eq(
          status: Clap::AutomationControl::AutomationStatus::DEPENDS_ON_ACTION,
          depends_on_action_id: 'action-1',
          depends_on_step_id: 'step-1',
        )
      end
    end
  end

  describe Clap::Exporter::Models::StepAutomationControlExporter do
    let(:automation) { described_class.new(workup).to_clap }

    it 'returns nil without step automation status' do
      expect(described_class.new({}).to_clap).to be_nil
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
