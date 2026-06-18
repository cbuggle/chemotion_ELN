# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::ReactionProcessActivityExporter do
  subject(:clap) { described_class.new(action).to_clap(starts_at: starts_at) }

  let(:starts_at) { 5_000 }
  let(:action) do
    create(
      :reaction_process_activity,
      activity_name: 'WAIT',
      workup: { duration: 15_000 }.deep_stringify_keys,
    )
  end

  it 'exports scoped to activity names' do
    expect(clap.wait.duration.to_h).to eq(value: 15.0, unit: :SECOND)
  end

  context 'with an unknown activity name' do
    let(:action) { create(:reaction_process_activity, activity_name: 'UNKNOWN') }

    it 'returns nil' do
      expect(clap).to be_nil
    end
  end
end
