# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vessel do
  it { is_expected.to have_one(:reaction_process_vessel) }
  it { is_expected.to have_one(:reaction_process).through(:reaction_process_vessel) }
end
