# frozen_string_literal: true

module Entities
  module ReactionProcessEditor
    class FractionEntity < Grape::Entity
      expose(
        :id, :position, :vials, :followup_activity_id
      )

      expose :followup_activity_name

      private

      def followup_activity_name
        followup_activity = object.followup_activity
        activity_name = followup_activity&.activity_name

        return 'DEFINE_FRACTION' unless followup_activity

        if activity_name == 'ANALYSIS'
          "#{activity_name}_#{followup_activity.workup['analysis_type']}"
        elsif activity_name == 'PURIFICATION'
          followup_activity.workup['purification_type']
        else
          activity_name
        end
      end
    end
  end
end
