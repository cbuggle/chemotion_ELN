# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap reaction process exporters' do
  before do
    ReactionProcessEditor::Ontology.create!(
      ontology_id: 'NCIT:C70669',
      label: 'Automation',
      name: 'Automation mode',
    )
  end

  describe Clap::Exporter::ReactionProcessStepExporter do
    let(:step) do
      create(
        :reaction_process_step,
        automation_mode: 'NCIT:C70669',
        automation_control: { status: 'STEP_COMPLETED' },
      )
    end
    let(:activity) do
      create(
        :reaction_process_activity,
        reaction_process_step: step,
        activity_name: 'WAIT',
        workup: { duration: 20_000 },
      )
    end
    let(:clap) do
      activity

      described_class.new(step).to_clap(starts_at: 10_000)
    end

    it 'exports step timing and actions' do
      expect(clap.to_h).to include(
        reaction_step_id: step.id,
        position: 1,
        start_time: { value: 10.0, unit: :SECOND },
        duration: { value: 20.0, unit: :SECOND },
        automation_mode: { id: 'NCIT:C70669', label: 'Automation', name: 'Automation mode' },
        automation_control: { step_status: :STEP_COMPLETED },
      )
    end
  end

  describe Clap::Exporter::ReactionProcessExporter do
    let(:reaction_process) do
      create(
        :reaction_process,
        default_conditions: { TEMPERATURE: { value: '21', unit: 'CELSIUS' } },
      )
    end
    let(:first_step) { create(:reaction_process_step, reaction_process: reaction_process, position: 0) }
    let(:second_step) { create(:reaction_process_step, reaction_process: reaction_process, position: 1) }
    let(:first_activity) do
      create(
        :reaction_process_activity,
        reaction_process_step: first_step,
        activity_name: 'WAIT',
        workup: { duration: 10_000 },
      )
    end
    let(:second_activity) do
      create(
        :reaction_process_activity,
        reaction_process_step: second_step,
        activity_name: 'WAIT',
        workup: { duration: 5_000 },
      )
    end
    let(:clap) do
      first_activity
      second_activity

      described_class.new(reaction_process).to_clap
    end

    it 'exports the current CLAP version' do
      expect(clap.clap_version).to eq('1.0.2')
    end

    it 'exports the reaction process id as reaction id' do
      expect(clap.reaction_id).to eq(reaction_process.id)
    end

    it 'exports reaction steps in position order' do
      expect(clap.reaction_steps.map(&:reaction_step_id)).to eq([first_step.id, second_step.id])
    end

    it 'uses accumulated preceding step durations as start times' do
      expect(clap.reaction_steps[1].start_time.to_h).to eq(value: 10.0, unit: :SECOND)
    end
  end

  describe Clap::Exporter::Models::DetectorExporter do
    let(:detector) do
      described_class.new(
        detector_ontology_id: 'NCIT:C70669',
        conditions: { 'TEMPERATURE' => { 'value' => '25', 'unit' => 'CELSIUS' } },
      ).to_clap
    end

    it 'exports detector ontology and conditions' do
      expect(detector.to_h).to include(
        ontology: { id: 'NCIT:C70669', label: 'Automation', name: 'Automation mode' },
        conditions: { temperature_control: { temperature: { value: 25.0, unit: :CELSIUS } } },
      )
    end
  end

  describe Clap::Exporter::Actions::SaveSampleActionExporter do
    let(:action) do
      create(
        :reaction_process_activity_save,
        workup: {
          acts_as: 'SAMPLE',
          target_amount: { value: '2', unit: 'mg' },
          sample_origin_type: 'ALL',
          molecular_entities: [{ label: 'entity' }],
        },
      )
    end
    let(:save_sample) { described_class.new(action).to_clap(starts_at: 0).save_sample }

    it 'exports saved sample metadata' do
      expect(save_sample.to_h).to include(
        sample_origin_type: :ALL,
        molecular_entities: [{ label: 'entity' }],
      )
    end
  end

  describe Clap::Exporter::Actions::SaveSample::PurificationOriginExporter do
    let(:action) do
      create(
        :reaction_process_activity_save,
        workup: {
          sample_origin_action_id: 'action-1',
          sample_origin_purification_step: { position: 2 },
          solvents_amount: { value: '1', unit: 'ml' },
        },
      )
    end
    let(:origin) { described_class.new(action).to_clap }

    it 'exports purification origin metadata' do
      expect(origin).to include(
        origin_action_id: 'action-1',
        origin_purification_step_position: 2,
        amount: have_attributes(volume: have_attributes(value: 1.0, unit: :MILLILITER)),
        solvents: [],
        extra_solvents: [],
      )
    end
  end
end
