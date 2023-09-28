# frozen_string_literal: true

  FactoryBot.define do
    factory :reaction_process, class: ReactionProcessEditor::ReactionProcess do
      reaction
    end
  end
