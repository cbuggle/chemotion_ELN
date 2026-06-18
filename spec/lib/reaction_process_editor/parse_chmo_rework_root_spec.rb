# frozen_string_literal: true

require 'rails_helper'

load Rails.root.join('lib/reaction_process_editor/parse_chmo_rework_root.rb')

describe 'lib/reaction_process_editor/parse_chmo_rework_root.rb' do
  let(:parser) { ParseChmo.new }
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

  describe '#run' do
    it 'writes a CSV for each configured root' do
      csv = []
      allow(CSV).to receive(:open).and_yield(csv)

      parser.run(doc)

      expect(csv).to include(['CHMO:1', 'CHMO: Root', '', 'http://example.test/CHMO_1', 'marker'])
    end
  end

  describe '#parse_root' do
    it 'returns the matching root node' do
      expect(parser.parse_label(parser.parse_root(doc: doc, chmo_id: 'CHMO_1'))).to eq('Root')
    end
  end

  describe '#parse_sub_nodes' do
    it 'returns descendant nodes' do
      expect(parser.parse_sub_nodes(doc: doc, chmo_id: 'CHMO_1').flatten.map do |node|
        parser.parse_chmo_id(node)
      end).to eq(['CHMO:2'])
    end
  end

  describe '#write_csv' do
    it 'writes nodes to CSV' do
      csv = []
      allow(CSV).to receive(:open).and_yield(csv)

      parser.write_csv(nodes: [parser.parse_root(doc: doc, chmo_id: 'CHMO_1')], filename: 'root.csv')

      expect(csv).to eq([['CHMO:1', 'CHMO: Root', '', 'http://example.test/CHMO_1', 'marker']])
    end
  end
end
