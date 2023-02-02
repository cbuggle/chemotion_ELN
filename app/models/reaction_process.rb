# frozen_string_literal: true

# == Schema Information
#
# Table name: reaction_processes
#
#  id          :uuid             not null, primary key
#  reaction_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  duration    :integer
#  starts_at   :datetime
#

class ReactionProcess < ApplicationRecord
  delegate :creator, to: :reaction
  belongs_to :reaction, optional: false

  has_many :reaction_process_vessel, dependent: :destroy
  has_many :vessels, through: :reaction_process_vessel, dependent: :destroy

  has_many :samples_preparations, dependent: :destroy

  has_many :reaction_process_steps, -> { includes([:vessel]) }, dependent: :destroy

  has_one :provenance, dependent: :destroy

  delegate :reaction_svg_file, to: :reaction

  def create_vessel(create_vessel_params)
    vessel = vessels.create create_vessel_params
    UserVessel.create(user: creator, vessel: vessel)
    vessel
  end

  def normalize_timestamps
    self.duration = reaction_process_steps.order(:position).reduce(0) do |sum, process_step|
      process_step.update(start_time: sum)
      sum + process_step.duration.to_i
    end
    save
  end

  def saved_sample_ids
    reaction_process_steps.includes([:reaction_process_actions]).map(&:saved_sample_ids).flatten.uniq
  end
end
