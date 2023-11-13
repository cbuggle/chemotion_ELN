# frozen_string_literal: true

module OrdKit
  module Exporter
    module Conditions
      class MotionConditionsExporter < OrdKit::Exporter::Conditions::Base
        # Works on ReactionProcessA ("CONDITION / MOTION")

        def to_ord
          StirringConditions.new(
            type: stirring_method_type,
            details: details,
            rate: stirring_rate,
            automation: automation,
          )
        end

        private

        def stirring_method_type
          OrdKit::StirringConditions::StirringMethodType.const_get condition['motion_type']
        rescue NameError
          OrdKit::StirringConditions::StirringMethodType::UNSPECIFIED
        end

        def details
          nil # n/a. Unkown in ELN.
        end

        def stirring_rate
          OrdKit::StirringConditions::StirringRate.new(
            # n/a. ELN works with RPM, doesn't care if that is low, medium, high.
            type: OrdKit::StirringConditions::StirringRate::StirringRateType::UNSPECIFIED,
            details: nil, # n/a. Unkown in ELN.
            rpm: condition.dig('speed', 'value').to_f,
          )
        end

        def automation
          Automation::AutomationType.const_get condition['motion_mode']
        rescue NameError
          Automation::AutomationType::UNSPECIFIED
        end
      end
    end
  end
end
