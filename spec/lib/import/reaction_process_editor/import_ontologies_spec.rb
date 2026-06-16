# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/import/reaction_process_editor/import_ontologies')

describe Import::ReactionProcessEditor::ImportOntologies do
  subject(:importer) { described_class.new }

  let(:csv_file) do
    file = Tempfile.new(['ontologies', '.csv'])
    file.write(<<~CSV)
      Ontology ID;Ontology Name;Custom Label;Link;Detectors;Solvents;Roles;Stationary Phase
      CHMO:imported;Name;Imported Label;https://example.test;PDA;CHMO:solvent;mode,NCIT:C70669(mode);CHMO:stationary
    CSV
    file.rewind
    Pathname.new(file.path)
  end

  before do
    stub_const('Import::ReactionProcessEditor::ImportDeviceMethods', Class.new do
      def execute; end
    end)
  end

  after do
    csv_file.delete
  end

  describe '#execute' do
    it 'imports active ontologies from CSV files' do
      allow(importer).to receive(:ontology_files).and_return([csv_file])

      importer.execute

      expect(ReactionProcessEditor::Ontology.find_by(ontology_id: 'CHMO:imported')).to have_attributes(
        label: 'Imported Label',
        active: true,
        detectors: ['PDA'],
        solvents: ['CHMO:solvent'],
        stationary_phase: ['CHMO:stationary'],
      )
    end
  end

  describe '#create_from_csv' do
    it 'ignores rows without ontology ids' do
      expect do
        importer.send(:create_from_csv, { 'Ontology ID' => nil })
      end.not_to change(ReactionProcessEditor::Ontology, :count)
    end

    it 'logs import errors' do
      ontology = instance_double(ReactionProcessEditor::Ontology,
                                 ontology_id: 'CHMO:error',
                                 errors: instance_double(ActiveModel::Errors, full_messages: ['invalid']))
      allow(ReactionProcessEditor::Ontology).to receive(:find_or_initialize_by).and_return(ontology)
      allow(ontology).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      allow(Rails.logger).to receive(:error)

      importer.send(:create_from_csv, { 'Ontology ID' => 'CHMO:error' })

      expect(Rails.logger).to have_received(:error).with(['invalid'])
    end
  end

  describe '#ontology_files' do
    it 'uses the configured ontology glob' do
      allow(Rails.root).to receive(:glob)

      importer.send(:ontology_files)

      expect(Rails.root).to have_received(:glob).with('data/reaction-process-editor/ontologies/*.csv')
    end
  end
end
