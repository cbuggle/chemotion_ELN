# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/import/reaction_process_editor/import_vessels')

describe Import::ReactionProcessEditor::ImportVessels do
  subject(:importer) { described_class.new }

  let!(:person) { create(:person) }
  let(:csv_file) do
    file = Tempfile.new(['vessels', '.csv'])
    file.write(<<~CSV)
      Vessel/Template;ID (short-label);Short-Description (Name);Type;Description (Details);Material;Vol.;Mode
      Vessel;V-1;Flask;Round bottom;Details;Glass;10 ml;"NCIT:C70669;NCIT:C63513"
    CSV
    file.rewind
    Pathname.new(file.path)
  end

  after do
    csv_file.delete
  end

  describe '#execute' do
    it 'imports vessel templates and vessels for people' do
      allow(importer).to receive(:ontology_files).and_return([csv_file])

      importer.execute

      expect(Vessel.find_by(short_label: 'V-1')).to have_attributes(
        name: 'Flask',
        creator: person,
      )
    end
  end

  describe '#create_from_csv' do
    it 'ignores rows without names' do
      expect do
        importer.send(:create_from_csv, { described_class::NAME_KEY => nil }, person)
      end.not_to change(VesselTemplate, :count)
    end

    it 'logs import errors' do
      allow(VesselTemplate).to receive(:find_or_initialize_by).and_raise(StandardError, 'broken')
      allow(Rails.logger).to receive(:error)

      importer.send(:create_from_csv, { described_class::NAME_KEY => 'Broken' }, person)

      expect(Rails.logger).to have_received(:error).with(nil).at_least(:once)
    end
  end

  describe '#vessel_type' do
    it 'returns vessel for vessel text' do
      expect(importer.send(:vessel_type, 'Vessel')).to eq('Vessel')
    end

    it 'returns vessel template for other text' do
      expect(importer.send(:vessel_type, 'Template')).to eq('VesselTemplate')
    end
  end

  describe '#ontology_files' do
    it 'uses the configured vessel glob' do
      allow(Rails.root).to receive(:glob)

      importer.send(:ontology_files)

      expect(Rails.root).to have_received(:glob).with('data/reaction-process-editor/vessels/*.csv')
    end
  end
end
