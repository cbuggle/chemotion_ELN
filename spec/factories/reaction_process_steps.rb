# frozen_string_literal: true

FactoryBot.define do
  factory :reaction_process_step do
    transient do
      reaction_process { ReactionProcess.first || create(:reaction_process) }
    end

    after(:build) do |process_step, object|
      process_step.reaction_process = object.reaction_process
      process_step.position = object.reaction_process.reaction_process_steps.count
    end
  end
end
