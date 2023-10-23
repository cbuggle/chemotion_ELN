# frozen_string_literal: true

FactoryBot.define do
  factory :reaction_process_step, class: 'ReactionProcessEditor::ReactionProcessStep' do
    transient do
      reaction_process { ReactionProcessEditor::ReactionProcess.first || create(:reaction_process) }
    end

    after(:build) do |process_step, object|
      process_step.reaction_process = object.reaction_process
      process_step.position = object.siblings.count
    end
  end
end
