# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::ReactionProcessStep do
  it { is_expected.to belong_to(:reaction_process) }
  it { is_expected.to belong_to(:reaction_process_vessel).optional }
end
