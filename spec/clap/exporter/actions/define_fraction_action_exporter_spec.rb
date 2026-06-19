# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clap::Exporter::Actions::DefineFractionActionExporter do
  subject(:define_fraction_export) { described_class.new(action).to_clap(starts_at: 0).define_fraction }

  let(:action) { create(:reaction_process_activity, activity_name: 'DEFINE_FRACTION') }

  before do
    create(:fraction, consuming_action: action)
  end

  it 'exports the generated fraction' do
    expect(define_fraction_export.fraction.position).to eq(1)
  end
end
