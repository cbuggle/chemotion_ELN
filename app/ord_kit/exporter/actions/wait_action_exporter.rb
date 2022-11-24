# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class WaitActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            wait: OrdKit::ReactionActionWait.new(
              duration: OrdKit::Time.new(
                value: model.duration,
                precision: nil,
                units: OrdKit::Time::TimeUnit::SECOND,
              ),
            ),
          }
        end
      end
    end
  end
end
