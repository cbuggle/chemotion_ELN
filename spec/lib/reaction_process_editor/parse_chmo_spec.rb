# frozen_string_literal: true

require 'rails_helper'

load Rails.root.join('lib/reaction_process_editor/parse_chmo.rb')

describe 'lib/reaction_process_editor/parse_chmo.rb' do
  let(:doc) do
    Nokogiri::XML(<<~XML)
      <rdf:RDF xmlns:owl="http://www.w3.org/2002/07/owl#"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
               xmlns:oboInOwl="http://www.geneontology.org/formats/oboInOwl#">
        <owl:Class rdf:about="http://example.test/CHMO_1">
          <oboInOwl:id>CHMO:1</oboInOwl:id>
          <rdfs:label>Root</rdfs:label>
        </owl:Class>
        <owl:Class rdf:about="http://example.test/CHMO_2">
          <rdfs:subClassOf rdf:resource="http://example.test/CHMO_1"/>
          <oboInOwl:id>CHMO:2</oboInOwl:id>
          <rdfs:label>Child</rdfs:label>
        </owl:Class>
      </rdf:RDF>
    XML
  end

  before do
    stub_const('ParseChmo::CHMO_IDS', ['CHMO_1'])
  end

  describe '.run' do
    it 'parses configured roots and writes them to CSV' do
      path = instance_double(Pathname)
      csv = []
      allow(Rails.root).to receive(:join).with('data/reaction-process-editor/chmo.owl').and_return(path)
      allow(path).to receive(:open).and_yield(StringIO.new('<xml/>'))
      allow(Nokogiri).to receive(:XML).and_return(doc)
      allow(CSV).to receive(:open).and_yield(csv)

      ParseChmo.run

      expect(csv).to include(['CHMO:1', 'Root', '', 'http://example.test/CHMO_1'])
    end
  end

  describe '.parse_root' do
    it 'returns the matching root node' do
      expect(ParseChmo.parse_label(ParseChmo.parse_root(doc: doc, chmo_id: 'CHMO_1'))).to eq('Root')
    end
  end

  describe '.parse_sub_nodes' do
    it 'returns descendant nodes' do
      expect(ParseChmo.parse_sub_nodes(doc: doc, chmo_id: 'CHMO_1').flatten.map do |node|
        ParseChmo.parse_chmo_id(node)
      end).to eq(['CHMO:2'])
    end
  end

  describe '.write_csv' do
    it 'writes unique nodes to CSV' do
      csv = []
      allow(CSV).to receive(:open).and_yield(csv)

      ParseChmo.write_csv(nodes: [ParseChmo.parse_root(doc: doc, chmo_id: 'CHMO_1')], filename: 'ontologies')

      expect(csv).to eq([['CHMO:1', 'Root', '', 'http://example.test/CHMO_1']])
    end
  end
end
