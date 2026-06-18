# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::ReactionProcessExporter do
  subject(:clap) { described_class.new(reaction_process).to_clap }

  let(:reaction_process) do
    create_default(
      :reaction_process,
      default_conditions: { TEMPERATURE: { value: '21', unit: 'CELSIUS' } },
    )
  end
  let(:first_step) { create(:reaction_process_step, position: 0) }
  let(:second_step) { create(:reaction_process_step, position: 1) }
  let(:first_activity) do
    create(
      :reaction_process_activity,
      reaction_process_step: first_step,
      activity_name: 'WAIT',
      workup: { duration: 10_000 },
    )
  end
  let(:second_activity) do
    create(
      :reaction_process_activity,
      reaction_process_step: second_step,
      activity_name: 'WAIT',
      workup: { duration: 5_000 },
    )
  end

  before do
    first_activity
    second_activity
  end

  it 'exports the current CLAP version' do
    expect(clap.clap_version).to eq('1.0.3')
  end

  it 'exports the reaction process id as reaction id' do
    expect(clap.reaction_id).to eq(reaction_process.id)
  end

  it 'exports reaction steps in position order' do
    expect(clap.reaction_steps.map(&:reaction_step_id)).to eq([first_step.id, second_step.id])
  end

  it 'uses accumulated preceding step durations as start times' do
    expect(clap.reaction_steps[1].start_time.to_h).to eq(value: 10.0, unit: :SECOND)
  end
end
