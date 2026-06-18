# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::WaitActionExporter do
  subject(:wait) { described_class.new(action).to_clap(starts_at: 0) }

  let(:action) do
    create(
      :reaction_process_activity,
      activity_name: 'WAIT',
      workup: { duration: 1000, EQUIPMENT: { value: %w[STIRRER bad] } }.deep_stringify_keys,
    )
  end

  it 'exports equipment and falls back for unknown equipment' do
    expect(wait.equipment.map(&:type)).to eq(%i[STIRRER UNSPECIFIED])
  end
end
