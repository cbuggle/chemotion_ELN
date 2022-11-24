# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class AnalysisActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          # TODO: Add more to the ELN Editor? A textfield 'analysis_number' is all we have.
          {
            analysis: OrdKit::ReactionActionAnalysis.new(
              details: workup['analysis_number'],
            ),
          }
        end
      end
    end
  end
end
