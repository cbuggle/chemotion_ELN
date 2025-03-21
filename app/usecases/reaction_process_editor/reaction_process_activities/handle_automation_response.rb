# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessActivities
      class HandleAutomationResponse
        def self.execute!(activity:, response_csv:)
          ActiveRecord::Base.transaction do
            Rails.logger.info("response_csv:")
            Rails.logger.info(response_csv)
            csv = CSV.parse(response_csv, headers: true, return_headers: false, col_sep: ';')

            row = csv[0]

            length = 3

            tray_type = row[0]
            vials = (row[1..row.length] * 6).map{ |value| value&.to_i}.in_groups_of(6 * length)

            activity.automation_response = { tray_type: tray_type, vials: vials}.stringify_keys

            activity.workup['AUTOMATION_STATUS'] = "AUTOMATION_RESPONDED"
            activity.save
          end
        end
      end
    end
  end
end
