# frozen_string_literal: true

# == Schema Information
#
# Table name: user_vessels
#
#  id         :uuid             not null, primary key
#  user_id    :integer
#  vessel_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserVessel < ApplicationRecord
  belongs_to :user
  belongs_to :vessel
end
