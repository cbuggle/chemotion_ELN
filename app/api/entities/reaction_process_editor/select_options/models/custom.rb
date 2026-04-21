# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    module SelectOptions
      module Models
        class Custom < Base
          def addition_speed_types
            titlecase_options_for(Clap::ReactionProcessAction::ActionAdd::AdditionSpeedType.constants)
          end
        end
      end
    end
  end
end
