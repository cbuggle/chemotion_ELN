# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessActivities
      class HandleAutomationStatus

        AUTOMATION_STATES = ['COMPLETED']

        def self.execute!(activity:, automation_status:)
          ActiveRecord::Base.transaction do

            return "unknown status #{automation_status}" unless AUTOMATION_STATES.include?(automation_status)

            activity.workup['AUTOMATION_STATUS'] = automation_status
            activity.save
          end
        end
      end
    end
  end
end
