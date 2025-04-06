# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessSteps
      class AppendPoolingGroupActivity
        def self.execute!(reaction_process_step:, pooling_group_params:, position:)
          ActiveRecord::Base.transaction do
            # Rails.logger.info('AppendPoolingGroupActivity vessel[id]')
            # Rails.logger.info(pooling_group_params['vessel']['id'] )
            # Rails.logger.info('AppendPoolingGroupActivity reaction_process_id')
            # Rails.logger.info(reaction_process_step.reaction_process_id)

            vessel = Usecases::ReactionProcessEditor::ReactionProcessVessels::CreateOrUpdate.execute!(
              reaction_process_id: reaction_process_step.reaction_process_id,
              reaction_process_vessel_params: pooling_group_params['vessel'],
            )

            activity_settings = activity_name(pooling_group_params['followUpAction'])

            activity = reaction_process_step.reaction_process_activities
                                            .new(activity_name: activity_settings[:activity_name])

            activity.reaction_process_vessel = vessel
            activity.workup = { vials: pooling_group_params['vials'].map(&:id) }
                              .merge(activity_settings[:workup])
                              .deep_stringify_keys

            ReactionProcessActivities::UpdatePosition.execute!(activity: activity, position: position)

            activity
          end
        end

        def self.activity_name(follow_up_action)
          activity_name = follow_up_action['value']

          if %w[FILTRATION EXTRACTION CRYSTALLIZATION].include?(activity_name)
            { activity_name: 'PURIFICATION',
              workup: { purification_type: activity_name } }
          elsif %w[ANALYSIS_CHROMATOGRAPHY ANALYSIS_SPECTROSCOPY].include?(activity_name)
            { activity_name: 'ANALYSIS',
              workup: { analysis_type: activity_name.delete_prefix('ANALYSIS_') } }

            # workup.action: ontologyId.action.analysis,
            # workup.class: ontologyId.class.spectroscopy,

          else
            { activity_name: activity_name, workup: {} }
          end
        end
      end
    end
  end
end
