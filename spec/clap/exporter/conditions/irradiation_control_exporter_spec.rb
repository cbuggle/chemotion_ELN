# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Conditions::IrradiationControlExporter do
  let(:control) do
    described_class.new(
      {
        'value' => '365',
        'unit' => 'NM',
        'power_is_ramp' => false,
        'power_end' => { 'value' => '1', 'unit' => 'WATT' },
      },
    ).to_clap
  end

  it 'omits power_end for non-ramp power' do
    expect(control.power_end).to be_nil
  end
end
