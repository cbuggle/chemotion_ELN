# frozen_string_literal: true

# == Schema Information
#
# Table name: vessel_preparations
#
#  id               :uuid             not null, primary key
#  vessel_id        :uuid
#  details          :string
#  preparation_type :string
#  medium_type      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class VesselPreparation < ApplicationRecord
  belongs_to :vessel
end
