# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class RemoveActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            removal: ReactionActionRemove.new(
              reaction_role: workup['acts_as'],
              input: Samples::RemoveSampleExporter.new(model).to_ord,
              replacement_medium: workup['replacement_medium'],
              remove_repetitions: workup['remove_repetitions'],
            ),
          }
        end
      end
    end
  end
end
