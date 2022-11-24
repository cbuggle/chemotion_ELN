# frozen_string_literal: true

FactoryBot.define do
  factory :vessel do
    vessel_type { 'ROUND_BOTTOM_FLASK' }
    material_type { 'GLASS' }
    volume_amount { 500 }
    volume_unit { 'MILLILITER' }
    environment_type { 'FUME_HOOD' }
    automation_type { 'AUTOMATED_TRUE' }

    transient do
      reaction_process { ReactionProcess.first || create(:reaction_process) }
      reaction_process_step {}
      user { User.first || create(:user) }
    end

    after(:create) do |vessel, obj|
      rp_vessel = ReactionProcessVessel.create(vessel: vessel, reaction_process: obj.reaction_process)
      obj.reaction_process_step.reaction_process_vessel = rp_vessel if obj.reaction_process_step
      obj.reaction_process_step&.save!

      UserVessel.create(user: obj.user, vessel: vessel)
    end
  end
end
