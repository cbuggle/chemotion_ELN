# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class AddActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            addition: ReactionActionAdd.new(
              reaction_role: workup['acts_as'],
              input: Samples::AddSampleExporter.new(model).to_ord,
            ),
          }
        end
      end
    end
  end
end
