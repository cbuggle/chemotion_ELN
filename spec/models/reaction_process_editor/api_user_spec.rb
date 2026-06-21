# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionProcessEditor::ApiUser do
  it 'inherits from User' do
    expect(described_class).to be < User
  end
end
