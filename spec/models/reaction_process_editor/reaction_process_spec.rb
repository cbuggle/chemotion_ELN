# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::ReactionProcess do
  it { is_expected.to belong_to(:reaction) }
  it { is_expected.to have_many(:vessels).through(:reaction_process_vessel) }

  it { is_expected.to have_many(:reaction_process_steps) }
end
