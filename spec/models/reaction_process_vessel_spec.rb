# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessVessel do
  it { is_expected.to belong_to(:reaction_process) }
  it { is_expected.to belong_to(:vessel) }

  it { is_expected.to have_many(:reaction_process_steps) }
end
