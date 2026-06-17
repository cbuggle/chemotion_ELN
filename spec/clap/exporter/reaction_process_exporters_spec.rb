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
    it 'exports step timing and actions' do
      step = create(
        :reaction_process_step,
        automation_mode: 'NCIT:C70669',
        automation_control: { status: 'STEP_COMPLETED' },
      )
      create(
        :reaction_process_activity,
        reaction_process_step: step,
        activity_name: 'WAIT',
        workup: { duration: 20_000 },
      )

      clap = described_class.new(step).to_clap(starts_at: 10_000)

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
    def build_reaction_process_clap
      reaction_process = create(
        :reaction_process,
        default_conditions: { TEMPERATURE: { value: '21', unit: 'CELSIUS' } },
      )
      first_step = create(:reaction_process_step, reaction_process: reaction_process, position: 0)
      second_step = create(:reaction_process_step, reaction_process: reaction_process, position: 1)
      create(
        :reaction_process_activity,
        reaction_process_step: first_step,
        activity_name: 'WAIT',
        workup: { duration: 10_000 },
      )
      create(
        :reaction_process_activity,
        reaction_process_step: second_step,
        activity_name: 'WAIT',
        workup: { duration: 5_000 },
      )

      [described_class.new(reaction_process).to_clap, reaction_process, first_step, second_step]
    end

    it 'exports the current CLAP version' do
      clap, = build_reaction_process_clap

      expect(clap.clap_version).to eq('1.0.2')
    end

    it 'exports the reaction process id as reaction id' do
      clap, reaction_process = build_reaction_process_clap

      expect(clap.reaction_id).to eq(reaction_process.id)
    end

    it 'exports reaction steps in position order' do
      clap, _reaction_process, first_step, second_step = build_reaction_process_clap

      expect(clap.reaction_steps.map(&:reaction_step_id)).to eq([first_step.id, second_step.id])
    end

    it 'uses accumulated preceding step durations as start times' do
      clap, = build_reaction_process_clap

      expect(clap.reaction_steps[1].start_time.to_h).to eq(value: 10.0, unit: :SECOND)
    end
  end

  describe Clap::Exporter::Models::DetectorExporter do
    it 'exports detector ontology and conditions' do
      detector = described_class.new(
        detector_ontology_id: 'NCIT:C70669',
        conditions: { 'TEMPERATURE' => { 'value' => '25', 'unit' => 'CELSIUS' } },
      ).to_clap

      expect(detector.to_h).to include(
        ontology: { id: 'NCIT:C70669', label: 'Automation', name: 'Automation mode' },
        conditions: { temperature_control: { temperature: { value: 25.0, unit: :CELSIUS } } },
      )
    end
  end

  describe Clap::Exporter::Actions::SaveSampleActionExporter do
    it 'exports saved sample metadata' do
      action = create(
        :reaction_process_activity_save,
        workup: {
          acts_as: 'SAMPLE',
          target_amount: { value: '2', unit: 'mg' },
          sample_origin_type: 'ALL',
          molecular_entities: [{ label: 'entity' }],
        },
      )

      save_sample = described_class.new(action).to_clap(starts_at: 0).save_sample

      expect(save_sample.to_h).to include(
        sample_origin_type: :ALL,
        molecular_entities: [{ label: 'entity' }],
      )
    end
  end

  describe Clap::Exporter::Actions::SaveSample::PurificationOriginExporter do
    it 'exports purification origin metadata' do
      action = create(
        :reaction_process_activity_save,
        workup: {
          sample_origin_action_id: 'action-1',
          sample_origin_purification_step: { position: 2 },
          solvents_amount: { value: '1', unit: 'ml' },
        },
      )

      origin = described_class.new(action).to_clap

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
