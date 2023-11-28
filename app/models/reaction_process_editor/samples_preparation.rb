# frozen_string_literal: true

# == Schema Information
#
# Table name: samples_preparations
#
#  id                  :bigint           not null, primary key
#  sample_id           :integer
#  reaction_process_id :uuid
#  preparations        :string           is an Array
#  equipment           :string           is an Array
#  details             :string
#  created_at          :datetime
#  updated_at          :datetime
#

module ReactionProcessEditor
  class SamplesPreparation < ApplicationRecord
    belongs_to :reaction_process
    belongs_to :sample, -> { includes(:molecule) }, inverse_of: :samples_preparations
  end
end
