# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessActivities
      class HandleAutomationResponse
        def self.execute!(activity:, response_csv:)
          ActiveRecord::Base.transaction do
            csv = CSV.parse(response_csv, headers: true, return_headers: false, col_sep: ';')

            row = csv[0]

            tray_type = row[0]
            # TODO: Establish length (& width) from tray_type definitions.
            length = 5
            vials = (row[1..row.length]).map{ |value| value&.to_i}.in_groups_of(length)

            activity.automation_response = { tray_type: tray_type, vials: vials}.stringify_keys

            activity.workup['AUTOMATION_STATUS'] = "AUTOMATION_RESPONDED"
            activity.save
          end
        end
      end
    end
  end
end
