# frozen_string_literal: true

module OrdKit
  module Exporter
    module Actions
      class MotionActionExporter < OrdKit::Exporter::Actions::Base
        private

        def step_action
          {
            motion: OrdKit::ReactionActionMotion.new(
              motion: motion,
            ),
          }
        end

        def motion
          StirringConditions.new(
            type: stirring_method_type,
            details: details,
            rate: stirring_rate,
            automation: automation,
          )
        end

        def stirring_method_type
          OrdKit::StirringConditions::StirringMethodType.const_get workup['motion_type']
        rescue NameError
          OrdKit::StirringConditions::StirringMethodType::UNSPECIFIED
        end

        def details
          nil # n/a. Unkown in ELN.
        end

        def stirring_rate
          OrdKit::StirringConditions::StirringRate.new(
            type: OrdKit::StirringConditions::StirringRate::StirringRateType::UNSPECIFIED, # n/a. ELN works with RPM, doesn't care if that is low, medium, high.
            details: nil, # n/a. Unkown in ELN.
            rpm: workup['motion_speed'].to_i,
          )
        end

        def automation
          Automation::AutomationType.const_get workup['motion_mode']
        rescue NameError
          Automation::AutomationType::UNSPECIFIED
        end
      end
    end
  end
end
