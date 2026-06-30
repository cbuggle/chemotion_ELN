# frozen_string_literal: true

require 'rails_helper'

describe Entities::ReactionProcessEditor::SelectOptions::Models::Materials do
  describe '#sample_options_for_user' do
    subject(:materials_select_options) { described_class.new }

    let(:user) { create(:person) }
    let(:sample) { create(:valid_sample, creator: user) }
    let(:collection) { create(:collection, user: user) }

    let(:reaction_process) { create(:reaction_process) }

    describe '#select_options_for' do
      subject(:select_options) { materials_select_options.select_options_for(reaction_process: reaction_process) }

      it 'returns select options hash' do
        expect(select_options).to be_a(Hash)
      end

      context 'when a selected reaction sample is merged with another sample' do
        let(:reaction_process) { create(:reaction_process, reaction: reaction) }
        let(:reaction) { create(:reaction, collections: [collection]) }
        let(:target_sample) { create(:sample, collections: [collection]) }
        let(:merged_source_sample) { create(:sample, collections: [collection], is_legacy: true) }

        before do
          create(:reactions_product_sample, reaction: reaction, sample: target_sample)
          SampleMerge.create!(
            reaction: reaction,
            source_sample: merged_source_sample,
            target_sample: target_sample,
            source_amount_mol: 1.0,
          )
        end

        it 'adds the merged sample to sample options' do
          expect(select_options[:SAMPLE]).to include(
            hash_including(value: merged_source_sample.id, acts_as: 'SAMPLE'),
          )
        end
      end
    end

    describe '#sample_options_for_user' do
      subject(:sample_options) { materials_select_options.sample_options_for_user(user: user) }

      before do
        CollectionsSample.create!(collection: collection, sample: sample)
      end

      it 'maps user samples to options' do
        expect(sample_options).to include(
          hash_including(value: sample.id, acts_as: 'SAMPLE'),
        )
      end
    end

    context 'without a user' do
      subject(:sample_options) { materials_select_options.sample_options_for_user(user: nil) }

      it 'returns an empty array' do
        expect(sample_options).to eq([])
      end
    end
  end
end
