# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Conditions::MotionControlExporter do
  it 'falls back for unknown motion control types' do
    expect(described_class.new({ 'motion_type' => 'bad' }).to_clap.type).to eq(:UNSPECIFIED)
  end
end
