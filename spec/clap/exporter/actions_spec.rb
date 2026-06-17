# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap action exporters' do
  def create_action(activity_name, workup = {})
    create(:reaction_process_activity, activity_name: activity_name, workup: workup.deep_stringify_keys)
  end

  describe Clap::Exporter::ReactionProcessActivityExporter do
    let(:action) { create_action('WAIT', duration: 15_000) }

    it 'dispatches known activity names' do
      expect(described_class.new(action).to_clap(starts_at: 5_000).wait.duration.to_h).to eq(value: 15.0, unit: :SECOND)
    end

    it 'returns nil for unknown activity names' do
      expect(described_class.new(create_action('UNKNOWN')).to_clap(starts_at: 0)).to be_nil
    end
  end

  describe Clap::Exporter::Actions::Base do
    let(:action) { create_action('WAIT') }

    it 'raises when used without a concrete action type' do
      expect { described_class.new(action).to_clap(starts_at: 0) }.to raise_error(/abstract/)
    end
  end

  describe Clap::Exporter::Actions::AddActionExporter do
    let(:action) do
      create(
        :reaction_process_activity_add_sample,
        workup: {
          acts_as: 'SAMPLE',
          target_amount: { value: '10', unit: 'mg' },
          addition_speed_type: 'FLOW_RATE',
          VELOCITY: { value: '2', unit: 'MLMIN' },
          TEMPERATURE: { value: '25', unit: 'CELSIUS', additional_information: 'AMBIENT' },
        },
      )
    end
    let(:addition) { described_class.new(action).to_clap(starts_at: 0).addition }

    it 'exports add action attributes' do
      expect(addition.to_h).to include(
        addition_speed_type: :FLOW_RATE,
        flow_rate: { value: 2.0, unit: :MILLILITER_PER_MINUTE },
        addition_conditions: {
          temperature_control: {
            temperature: { value: 25.0, unit: :CELSIUS },
            temperature_control_type: :AMBIENT,
          },
        },
      )
    end
  end

  describe Clap::Exporter::Actions::ConditionsActionExporter do
    let(:action) do
      create_action(
        'CONDITION',
        TEMPERATURE: { value: '25', unit: 'CELSIUS', additional_information: 'AMBIENT' },
        EQUIPMENT: { value: ['STIRRER'] },
      )
    end
    let(:clap) { described_class.new(action).to_clap(starts_at: 0) }

    it 'exports condition action attributes' do
      expect(clap.to_h).to include(equipment: [{ type: :STIRRER }], conditions: hash_including(:temperature_control))
    end
  end

  describe Clap::Exporter::Actions::GasExchangeActionExporter do
    let(:action) { create_action('GAS_EXCHANGE', gas_type: [{ id: 'GAS:1', label: 'Nitrogen', ratio: 1 }]) }
    let(:gas_exchange) { described_class.new(action).to_clap(starts_at: 0).gas_exchange }

    before do
      ReactionProcessEditor::Ontology.create!(ontology_id: 'GAS:1', label: 'Nitrogen', name: 'Nitrogen')
    end

    it 'exports gas type ratios' do
      expect(gas_exchange.to_h).to eq(
        gas_type: [
          {
            solvent: { label: 'Nitrogen', ontology: { id: 'GAS:1', label: 'Nitrogen', name: 'Nitrogen' } },
            ratio: '1',
          },
        ],
      )
    end
  end

  describe Clap::Exporter::Actions::MixingActionExporter do
    let(:action) { create_action('MIXING', speed: { value: '600', unit: 'RPM' }) }

    it 'exports mixing speed' do
      expect(described_class.new(action).to_clap(starts_at: 0).mixing.speed.to_h).to eq(value: 600.0, unit: :RPM)
    end
  end

  describe Clap::Exporter::Actions::TransferActionExporter do
    let(:action) do
      create(
        :reaction_process_activity_add_sample,
        activity_name: 'TRANSFER',
        workup: {
          acts_as: 'SAMPLE',
          source_step_id: 'source-step',
          target_step_id: 'target-step',
          target_amount: { value: '1', unit: 'ml', percentage: 25 },
        },
      )
    end
    let(:transfer) { described_class.new(action).to_clap(starts_at: 0).transfer }

    it 'exports transfer source and target' do
      expect(transfer.to_h).to include(
        source_reaction_step_id: 'source-step',
        target_reaction_step_id: 'target-step',
        amount: { volume: { value: 1.0, unit: :MILLILITER } },
        percentage: { value: 25.0 },
      )
    end
  end

  describe Clap::Exporter::Actions::Analysis::ElementalExporter do
    let(:action) do
      create_action(
        'ANALYSIS_ELEMENTAL',
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        detector: ['DET:1'],
      )
    end
    let(:analysis) { described_class.new(action).to_clap(starts_at: 0).analysis_elemental }

    before do
      ReactionProcessEditor::Ontology.create!(ontology_id: 'DET:1', label: 'Detector', name: 'Detector')
    end

    it 'exports samples, entities, and detector ontologies' do
      expect(analysis.to_h).to eq(
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        detectors: [{ id: 'DET:1', label: 'Detector', name: 'Detector' }],
      )
    end
  end

  describe Clap::Exporter::Actions::Analysis::SpectroscopyExporter do
    let(:action) do
      create_action(
        'ANALYSIS_SPECTROSCOPY',
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        solvents: [{ label: 'solvent', ratio: 1 }],
      )
    end
    let(:analysis) { described_class.new(action).to_clap(starts_at: 0).analysis_spectroscopy }

    it 'exports samples, entities, and solvents' do
      expect(analysis.to_h).to eq(
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        solvents: [{ solvent: { label: 'solvent' }, ratio: '1' }],
      )
    end
  end

  describe Clap::Exporter::Actions::DefineFractionActionExporter do
    let(:action) { create_action('DEFINE_FRACTION') }
    let(:fraction) { create(:fraction, consuming_action: action) }
    let(:define_fraction) do
      fraction

      described_class.new(action).to_clap(starts_at: 0).define_fraction
    end

    it 'exports the generated fraction' do
      expect(define_fraction.fraction.position).to eq(1)
    end
  end

  describe Clap::Exporter::Actions::DiscardActionExporter do
    let(:action) { create_action('DISCARD') }
    let(:fraction) { create(:fraction, consuming_action: action) }
    let(:discard) do
      fraction

      described_class.new(action).to_clap(starts_at: 0).discard
    end

    it 'exports the consumed fraction' do
      expect(discard.fraction.parent_action_id).to eq(
        fraction.parent_action_id,
      )
    end
  end

  describe Clap::Exporter::Actions::EvaporationActionExporter do
    let(:action) do
      create_action(
        'EVAPORATION',
        origin_type: 'DIVERSE_SOLVENTS',
        solvents: [{ label: 'solvent', ratio: 3 }],
        solvents_amount: { value: '4', unit: 'ml' },
      )
    end
    let(:evaporation) { described_class.new(action).to_clap(starts_at: 0).evaporation }

    it 'exports diverse solvent evaporation' do
      expect(evaporation.to_h).to eq(
        diverse_solvents: {
          solvents: [{ solvent: { label: 'solvent' }, ratio: '3' }],
          solvents_amount: { volume: { value: 4.0, unit: :MILLILITER } },
        },
      )
    end
  end

  describe Clap::Exporter::Actions::Purification::CentrifugationExporter do
    let(:action) do
      create_action(
        'CENTRIFUGATION',
        PRESSURE: { value: '2', unit: 'BAR' },
        TEMPERATURE: { value: '4', unit: 'CELSIUS' },
        SPEED: { value: '1000', unit: 'RPM' },
      )
    end
    let(:centrifugation) { described_class.new(action).to_clap(starts_at: 0).centrifugation }

    it 'exports centrifugation conditions' do
      expect(centrifugation.to_h).to include(
        pressure: { value: 2.0, unit: :BAR },
        temperature: { value: 4.0, unit: :CELSIUS },
        speed: { value: 1000.0, unit: :RPM },
      )
    end
  end

  describe Clap::Exporter::Actions::Purification::CrystallizationExporter do
    let(:action) do
      create_action(
        'CRYSTALLIZATION',
        purification_steps: [{ solvents: [{ label: 'solvent', ratio: 1 }] }],
        amount: { value: '5', unit: 'mg' },
        TEMPERATURE: { value: '5', unit: 'CELSIUS' },
        heating_duration: 10_000,
        cooling_duration: 20_000,
        crystallization_mode: 'COLD',
      )
    end
    let(:crystallization) { described_class.new(action).to_clap(starts_at: 0).crystallization }

    it 'exports crystallization parameters' do
      expect(crystallization.to_h).to include(
        amount: { mass: { value: 5.0, unit: :MILLIGRAM } },
        temperature: { value: 5.0, unit: :CELSIUS },
        heating_duration: { value: 10.0, unit: :SECOND },
        cooling_duration: { value: 20.0, unit: :SECOND },
        crystallization_mode: :COLD,
      )
    end
  end

  describe Clap::Exporter::Actions::Purification::ExtractionExporter do
    let(:action) do
      create_action(
        'EXTRACTION',
        phase: 'ORGANIC',
        purification_steps: [{
          solvents: [{ label: 'solvent', ratio: 1 }],
          amount: { value: '1', unit: 'ml' },
          flow_rate: { value: '2', unit: 'MLMIN' },
          duration: 30_000,
        }],
      )
    end
    let(:extraction) { described_class.new(action).to_clap(starts_at: 0).extraction }

    it 'exports extraction steps' do
      expect(extraction.to_h).to include(
        phase: :ORGANIC,
        steps: [hash_including(duration: { value: 30.0, unit: :SECOND })],
      )
    end
  end

  describe Clap::Exporter::Actions::Purification::FiltrationExporter do
    let(:action) do
      create_action(
        'FILTRATION',
        filtration_mode: 'KEEP_SUPERNATANT',
        purification_steps: [{
          solvents: [{ label: 'solvent', ratio: 1 }],
          amount: { value: '1', unit: 'ml' },
          repetitions: { value: 2 },
          rinse_vessel: true,
          duration: 30_000,
        }],
      )
    end
    let(:filtration) { described_class.new(action).to_clap(starts_at: 0).filtration }

    it 'exports filtration steps' do
      expect(filtration.to_h).to include(filtration_mode: :KEEP_SUPERNATANT, steps: [hash_including(repetitions: 2)])
    end
  end

  describe Clap::Exporter::Actions::Purification::ChromatographyExporter do
    let(:action) do
      create_action(
        'CHROMATOGRAPHY',
        stationary_phase: 'silica',
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        purification_steps: [{
          solvents: [{ label: 'solvent', ratio: 1 }],
          amount: { value: '1', unit: 'ml' },
          flow_rate: { value: '2', unit: 'MLMIN' },
          duration: 30_000,
          step_mode: 'SEPARATION',
          prod_mode: 'PROD',
        }],
      )
    end
    let(:chromatography) { described_class.new(action).to_clap(starts_at: 0).chromatography }

    it 'exports chromatography steps' do
      expect(chromatography.to_h).to include(
        stationary_phase: 'silica',
        samples: [{ label: 'sample' }],
        molecular_entities: [{ label: 'entity' }],
        steps: [hash_including(step: :SEPARATION, prod: :PROD)],
      )
    end
  end
end
