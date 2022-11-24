# frozen_string_literal: true

module OrdKit
  module Exporter
    module Reactions
      class ReactionStepExporter < OrdKit::Exporter::Base
        def to_ord
          OrdKit::ReactionStep.new(
            reaction_step_id: model.id,
            position: model.position,
            setup: setup,
            actions: reaction_actions,
            start_time: start_time,
            duration: duration,
            outcomes: outcomes,
          )
        end

        private

        def setup
          ReactionSetupExporter.new(model).to_ord
        end

        def reaction_actions
          model.reaction_process_actions.order(:position).filter_map do |rpa|
            ReactionActionExporter.new(rpa).to_ord
          end
        end

        def start_time
          OrdKit::Time.new(
            value: model.start_time.to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def duration
          OrdKit::Time.new(
            value: model.duration.to_i,
            precision: nil,
            units: OrdKit::Time::TimeUnit::SECOND,
          )
        end

        def outcomes
          # TODO: We might want to collect saved intermediate samples
        end
      end
    end
  end
end
