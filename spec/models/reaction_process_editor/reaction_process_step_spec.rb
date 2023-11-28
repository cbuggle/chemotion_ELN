# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::ReactionProcessStep do
  it { is_expected.to belong_to(:reaction_process) }
  it { is_expected.to belong_to(:vessel).optional(true) }
  it { is_expected.to have_many(:reaction_process_actions).dependent(:destroy) }
end
