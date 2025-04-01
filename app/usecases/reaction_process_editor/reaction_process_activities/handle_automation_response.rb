# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessActivities
      class HandleAutomationResponse
        def self.execute!(activity:, response_csv:)
          ActiveRecord::Base.transaction do
            csv = CSV.parse(response_csv, headers: true, return_headers: false, col_sep: ';')

            automation_response = csv.map do |row|
              # row = csv[0]

              tray_type = row[0]
              # TODO: Establish length (& width) from tray_type definitions.
              vial_columns = 5
              vials = (row[1..row.length]).map { |value| value&.to_i }
              { tray_type: tray_type, vial_columns: vial_columns, vials: vials }.deep_stringify_keys
            end

            activity.automation_response = automation_response

            activity.workup['AUTOMATION_STATUS'] = 'AUTOMATION_RESPONDED'
            activity.save
          end
        end
      end
    end
  end
end
