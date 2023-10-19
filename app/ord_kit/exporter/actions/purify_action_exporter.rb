# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class PurifyActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            purify: OrdKit::ReactionActionPurify.new(
              type: purify_type,
              filtration_mode: filtration_mode,
              automation: automation,
              solvents: solvents,
              ratio: ratio,
            ),
          }
        end

        def purify_type
          OrdKit::ReactionActionPurify::PurifyType.const_get workup['purify_type']
        rescue NameError
          OrdKit::ReactionActionPurify::PurifyType.UNSPECIFIED
        end

        def filtration_mode
          return unless workup['purify_type'] == 'FILTRATION'

          OrdKit::ReactionActionPurify::FiltrationMode.const_get workup['filtration_mode']
        rescue NameError
          OrdKit::ReactionActionPurify::FiltrationMode.UNSPECIFIED
        end

        def automation
          Automation::AutomationType.const_get workup['purify_automation']
        rescue NameError
          Automation::AutomationType::UNSPECIFIED
        end

        def solvents
          Array(workup['purify_solvent_sample_ids']).filter_map do |sample_id|
            OrdKit::Exporter::Compounds::PurifySolventExporter.new(sample_id).to_ord
          end
        end

        def ratio
          workup['purify_ratio']
        end
      end
    end
  end
end
