# frozen_string_literal: true

RSpec.describe Usecases::ReactionProcessEditor::ReactionProcessSteps::AppendPoolingGroupActivity do
  subject(:append_activity) do
    described_class.execute!(reaction_process_step: process_step,
                             pooling_group_params: pooling_group_params,
                             position: insert_before)
  end

  let!(:process_step) { create_default(:reaction_process_step) }
  let!(:existing_actions) { create_list(:reaction_process_activity, 3) }
  let(:insert_before) { nil }

  let(:pooling_group_params) do
    [{ activity_name: 'DISCARD', workup: { SOME: 'WORKUP' } },
     { activity_name: 'WAIT', workup: { SOME: 'WORKUP' } }].deep_stringify_keys
  end

  let(:created_action) { ReactionProcessEditor::ReactionProcess.order(:crated_at).last }

  it 'adds action' do
    expect { append_activity }.to change(process_step.reaction_process_activities, :length).by(1)
  end

  it 'returns action' do
    expect(append_activity.attributes).to include(activity_params)
  end

  it 'appends on last position' do
    expect(append_activity.position).to eq existing_actions.length
  end

  it 'triggers ReactionProcessActivities::Update' do
    allow(Usecases::ReactionProcessEditor::ReactionProcessActivities::Update).to receive(:execute!)

    append_activity

    expect(Usecases::ReactionProcessEditor::ReactionProcessActivities::Update).to have_received(:execute!).with(
      activity: instance_of(ReactionProcessEditor::ReactionProcessActivity),
      activity_params: activity_params,
    )
  end
end
