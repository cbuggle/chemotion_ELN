# frozen_string_literal: true
module ReactionProcessEditor
  class ReactionProcessVessel < ApplicationRecord
    acts_as_paranoid

    belongs_to :reaction_process
    belongs_to :vessel

    delegate :creator, to: :reaction_process
  end
end
