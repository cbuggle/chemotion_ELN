# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessActivities
      class HandleAutomationResponse
        # TODO: maybe find a better place for vial plate constants

        VIAL_PLATES = {
          # rubocop:disable Naming/VariableNumber # Don't rubocop VialPlate name constants provided by automation lab.
          HS_1: { columns: 1, vial_count: 1 },
          HS_15: { columns: 5, vial_count: 15 },
          HS_54: { columns: 6, vial_count: 54 },
          # rubocop:enable Naming/VariableNumber
        }.deep_stringify_keys

        def self.execute!(activity:, response_csv:)
          ActiveRecord::Base.transaction do
            csv = CSV.parse(response_csv, headers: true, return_headers: false, col_sep: ';')

            automation_response = csv.map do |row|
              tray_type = row[0]
              vial_plate = VIAL_PLATES[tray_type]
              vials = (row[1..vial_plate['vial_count']]).map { |value| value&.to_i }
              { tray_type: tray_type, vial_columns: vial_plate['columns'], vials: vials }.deep_stringify_keys
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
