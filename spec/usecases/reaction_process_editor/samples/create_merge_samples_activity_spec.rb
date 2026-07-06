# frozen_string_literal: true

RSpec.describe Usecases::ReactionProcessEditor::Samples::CreateMergeSamplesActivity do
  subject(:usecase) do
    described_class.execute!(
      current_user: current_user,
      reaction: reaction,
      source_sample: source_sample,
      target_sample: target_sample,
    )
  end

  shared_examples 'invalid merge sample activity input' do |message|
    it 'raises an error' do
      expect { usecase }.to raise_error(ArgumentError, message)
    end

    it 'does not create a reaction process step' do
      expect { execute_usecase_ignoring_argument_error }.not_to(
        change(ReactionProcessEditor::ReactionProcessStep, :count),
      )
    end

    it 'does not create a reaction process activity' do
      expect { execute_usecase_ignoring_argument_error }.not_to(
        change(ReactionProcessEditor::ReactionProcessActivity, :count),
      )
    end
  end

  def execute_usecase_ignoring_argument_error
    usecase
  rescue ArgumentError
    nil
  end

  let(:owner) { create(:user) }
  let(:current_user) { owner }
  let(:collection) { create(:collection, user: owner) }
  let(:reaction) { create(:valid_reaction, creator: owner, collections: [collection]) }
  let(:source_sample) { create(:sample, collections: [collection]) }
  let(:target_sample) { create(:sample, collections: [collection]) }

  before do
    create(:reactions_product_sample, reaction: reaction, sample: source_sample) if reaction && source_sample
    if reaction && target_sample && target_sample != source_sample
      create(:reactions_product_sample, reaction: reaction, sample: target_sample)
    end
  end

  it 'creates a reaction process step' do
    expect { usecase }.to change(ReactionProcessEditor::ReactionProcessStep, :count).by(1)
  end

  it 'creates one merge samples activity in the step' do
    expect(usecase.reaction_process_activities.length).to eq(1)
  end

  it 'sets the activity name' do
    expect(usecase.reaction_process_activities.first.activity_name).to eq('MERGE_SAMPLES')
  end

  it 'stores the source sample in the activity workup' do
    expect(usecase.reaction_process_activities.first.workup['source_sample_id']).to eq(source_sample.id)
  end

  it 'stores the target sample in the activity workup' do
    expect(usecase.reaction_process_activities.first.workup['target_sample_id']).to eq(target_sample.id)
  end

  it 'stores the default automation mode on the created step' do
    expect(usecase.automation_mode).to eq(
      Entities::ReactionProcessEditor::Constants::Ontologies::DEFAULT_AUTOMATION_MODE,
    )
  end

  it 'stores the amount unit as ml when the target sample has a positive density' do
    target_sample.update!(density: 2.0, real_amount_value: 3.0, real_amount_unit: 'ml')

    expect(usecase.reaction_process_activities.first.workup.dig('amount', 'unit')).to eq('ml')
  end

  it 'stores the amount value as real volume when the target sample has a positive density' do
    target_sample.update!(density: 2.0, real_amount_value: 3.0, real_amount_unit: 'ml')

    expect(usecase.reaction_process_activities.first.workup.dig('amount', 'value')).to eq(
      target_sample.real_amount_ml,
    )
  end

  it 'stores the amount unit as g when the target sample has no positive density' do
    target_sample.update!(density: 0.0, real_amount_value: 3.0, real_amount_unit: 'g')

    expect(usecase.reaction_process_activities.first.workup.dig('amount', 'unit')).to eq('g')
  end

  it 'stores the amount value as real mass when the target sample has no positive density' do
    target_sample.update!(density: 0.0, real_amount_value: 3.0, real_amount_unit: 'g')

    expect(usecase.reaction_process_activities.first.workup.dig('amount', 'value')).to eq(
      target_sample.real_amount_g,
    )
  end

  it 'creates the step on the reaction process for the reaction' do
    expect(usecase.reaction_process).to eq(reaction.reload.reaction_process)
  end

  it 'sets the step position to the amount of already existing steps' do
    reaction_process = create(:reaction_process, reaction: reaction, user: current_user)
    create_list(:reaction_process_step, 2, reaction_process: reaction_process)

    expect(usecase.position).to eq(2)
  end

  it 'sets the activity automation ordinal' do
    expect(usecase.reaction_process_activities.first.automation_ordinal).to eq(1)
  end

  context 'when the reaction already has a reaction process' do
    let!(:reaction_process) do
      create(:reaction_process, reaction: reaction, user: current_user, automation_ordinal: 3)
    end

    it 'uses the existing reaction process' do
      expect(usecase.reaction_process).to eq(reaction_process)
    end

    it 'increments the existing reaction process automation ordinal' do
      expect { usecase }.to change { reaction_process.reload.automation_ordinal }.from(3).to(4)
    end
  end

  context 'without current_user' do
    let(:current_user) { nil }

    it_behaves_like 'invalid merge sample activity input', 'current_user is required'
  end

  context 'without reaction' do
    let(:reaction) { nil }

    it_behaves_like 'invalid merge sample activity input', 'reaction is required'
  end

  context 'without source_sample' do
    let(:source_sample) { nil }

    it_behaves_like 'invalid merge sample activity input', 'source_sample is required'
  end

  context 'without target_sample' do
    let(:target_sample) { nil }

    it_behaves_like 'invalid merge sample activity input', 'target_sample is required'
  end

  context 'when source_sample equals target_sample' do
    let(:target_sample) { source_sample }

    it_behaves_like 'invalid merge sample activity input', 'source_sample equals target_sample'
  end

  context 'when source_sample is not a product of the reaction' do
    before { reaction.reactions_product_samples.where(sample_id: source_sample.id).destroy_all }

    it_behaves_like 'invalid merge sample activity input', 'source_sample must be a product of this reaction'
  end

  context 'when source_sample was already merged into target_sample' do
    before do
      reaction.reactions_product_samples.where(sample_id: source_sample.id).destroy_all
      SampleMerge.create!(
        reaction: reaction,
        source_sample: source_sample,
        target_sample: target_sample,
        source_amount_mol: 1.0,
      )
    end

    it 'creates a merge samples activity' do
      expect(usecase.reaction_process_activities.first.activity_name).to eq('MERGE_SAMPLES')
    end
  end

  context 'when target_sample is not a product of the reaction' do
    before { reaction.reactions_product_samples.where(sample_id: target_sample.id).destroy_all }

    it_behaves_like 'invalid merge sample activity input', 'target_sample must be a product of this reaction'
  end
end
