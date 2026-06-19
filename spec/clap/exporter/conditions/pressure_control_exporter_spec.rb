# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Conditions::PressureControlExporter do
  subject(:control_export) { described_class.new(workup).to_clap }

  let(:workup) { { 'value' => '', 'unit' => 'MBAR' } }

  it 'omits blank pressure values' do
    expect(control_export.pressure).to be_nil
  end
end
