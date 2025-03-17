# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Automation Status" do
  let!(:reaction_process) { create_default(:reaction_process) }

  let!(:process_steps) { create_list(:reaction_process_steps, 4)}

  describe 'automation status' do

    it "does not halts_automation?" do
    end

    it "halts_automation when activity halts" do
    end
  end
end
