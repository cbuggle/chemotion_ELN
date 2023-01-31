# frozen_string_literal: true

# == Schema Information
#
# Table name: media
#
#  id            :uuid             not null, primary key
#  sum_formula   :string
#  sample_name   :string
#  molecule_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  type          :string
#

module Medium
  class Medium < ApplicationRecord
    # STI Base Class for Medium::MediumSample, Medium::Additive, Medium::DiverseSolvent
    # self.abstract_class = true

    def short_label
      label
    end

    def preferred_label
      label
    end
  end
end
