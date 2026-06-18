# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::ConditionsActionExporter do
  subject(:clap) { described_class.new(action).to_clap(starts_at: 0) }

  let(:action) do
    create(
      :reaction_process_activity,
      activity_name: 'CONDITION',
      workup: {
        TEMPERATURE: { value: '25', unit: 'CELSIUS', additional_information: 'AMBIENT' },
        EQUIPMENT: { value: ['STIRRER'] },
      }.deep_stringify_keys,
    )
  end

  it 'exports condition action attributes' do
    expect(clap.to_h).to include(equipment: [{ type: :STIRRER }], conditions: hash_including(:temperature_control))
  end
end
