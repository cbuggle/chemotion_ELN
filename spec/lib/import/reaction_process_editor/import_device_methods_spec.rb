# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/import/reaction_process_editor/import_device_methods')

describe Import::ReactionProcessEditor::ImportDeviceMethods do
  subject(:importer) { described_class.new }

  let(:ontology) do
    ReactionProcessEditor::Ontology.create!(ontology_id: 'CHMO:device', label: 'Device')
  end
  let(:csv_file) do
    file = Tempfile.new(['CHMO_device', '.csv'])
    file.write(<<~CSV)
      Method Name;Default Inj. Vol.;Detectors;Solvent;Stationary Phase;Description;Steps
      Device_Method Suffix;2000;PDA (220,254);CHMO:solvent;CHMO:stationary;Description;[]
    CSV
    file.rewind
    Pathname.new(file.path)
  end

  after do
    csv_file.delete
  end

  describe '#execute' do
    it 'imports active device methods from CSV files' do
      allow(importer).to receive(:device_methods_files).and_return([csv_file])
      allow(importer).to receive(:ontology_for_filename).and_return(ontology)

      importer.execute

      expect(ReactionProcessEditor::OntologyDeviceMethod.last).to have_attributes(
        ontology: ontology,
        active: true,
        default_inject_volume: { 'value' => 2, 'unit' => 'ml' },
      )
    end
  end

  describe '#method_options' do
    it 'keeps small injection volumes in microliters' do
      row = {
        'Default Inj. Vol.' => '25',
        'Detectors' => 'MS (positive)',
        'Solvent' => 'A; B',
        'Stationary Phase' => 'Phase',
        'Description' => 'Description',
        'Steps' => 'invalid',
      }

      expect(importer.send(:method_options, method_csv: row)).to include(
        default_inject_volume: { value: 25, unit: 'mcl' },
        steps: [],
      )
    end
  end

  describe '#analysis_default_values' do
    it 'maps metric defaults' do
      expect(importer.send(:analysis_default_values, data_type: 'METRIC', values: '55', unit: 'CELSIUS')).to eq(
        value: '55',
        unit: 'CELSIUS',
      )
    end
  end

  describe '#detector_analysis_defaults' do
    it 'returns an empty array for unknown detectors' do
      expect(importer.send(:detector_analysis_defaults, 'UNKNOWN', 'value')).to eq([])
    end
  end

  describe '#stationary_phase_analysis_defaults' do
    it 'returns temperature defaults' do
      expect(importer.send(:stationary_phase_analysis_defaults, '22')).to eq(
        analysis_defaults: {
          TEMPERATURE: {
            value: '22',
            unit: 'CELSIUS',
          },
        },
      )
    end
  end

  describe '#create_from_csv' do
    it 'logs import errors' do
      method = instance_double(ReactionProcessEditor::OntologyDeviceMethod,
                               errors: instance_double(ActiveModel::Errors, full_messages: ['invalid']))
      allow(ReactionProcessEditor::OntologyDeviceMethod).to receive(:find_or_initialize_by).and_return(method)
      allow(method).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      importer.define_singleton_method(:csv) { { 'Method Name' => 'Broken' } }
      allow(Rails.logger).to receive(:error)

      importer.send(:create_from_csv, method_csv: { 'Method Name' => 'Broken' }, ontology: ontology)

      expect(Rails.logger).to have_received(:error).with(['invalid'])
    end
  end

  describe '#ontology_for_filename' do
    it 'finds the ontology matching the filename' do
      ontology

      expect(importer.send(:ontology_for_filename, Pathname.new('CHMO_device.csv'))).to eq(ontology)
    end
  end

  describe '#device_methods_files' do
    it 'uses the configured device methods glob' do
      allow(Rails.root).to receive(:glob)

      importer.send(:device_methods_files)

      expect(Rails.root).to have_received(:glob).with('data/reaction-process-editor/devices/*.csv')
    end
  end
end
