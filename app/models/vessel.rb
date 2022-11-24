# frozen_string_literal: true

# == Schema Information
#
# Table name: vessels
#
#  id                    :uuid             not null, primary key
#  reaction_process_id :uuid
#  name                  :string
#  details               :string
#  vessel_type           :string
#  volume_unit           :string
#  environment_type      :string
#  material_type         :string
#  automation_type       :string
#  environment_details   :string
#  material_details      :string
#  volume_amount         :string
#  preparations          :string
#  attachment_details    :string
#  created_at            :datetime
#  updated_at            :datetime
#  attachments           :string           is an Array
#

class Vessel < ApplicationRecord
  has_one :reaction_process_vessel, dependent: :destroy
  has_one :reaction_process, through: :reaction_process_vessel

  has_many :vessel_preparations
  has_many :vessel_attachments

  has_one :user_vessel, dependent: :destroy
  has_one :user, through: :user_vessel

  def self.create_and_assign(params:, user:)
    vessel = create(params[:vessel])
    UserVessel.create(user: user, vessel: vessel)

    reaction_process = ReactionProcess.find_by(id: params[:reaction_process_id])
    if reaction_process && params[:assign_to_reaction]
      ReactionProcessVessel.create(reaction_process: reaction_process,
                                     vessel: vessel)
    end
    vessel
  end

  def creator
    user_vessel&.user || reaction_process&.creator
  end
end
