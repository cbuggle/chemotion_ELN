# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_process_vessel
#
#  id                    :uuid             not null, primary key
#  reaction_process_id :uuid
#  vessel_id             :uuid
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ReactionProcessVessel < ApplicationRecord
  belongs_to :reaction_process
  belongs_to :vessel

  has_many :reaction_process_steps
end
