# frozen_string_literal: true

module ReactionProcessEditor
  class ReactionProcessActivityAPI < Grape::API
    include Grape::Extensions::Hashie::Mash::ParamBuilder

    helpers StrongParamsHelpers

    rescue_from :all

    namespace :reaction_process_activities do
      route_param :id, format: :uuid do
        before do
          @activity = ::ReactionProcessEditor::ReactionProcessActivity.find_by(id: params[:id])
          error!('404 Not Found', 404) unless @activity&.creator == current_user
        end

        params do
          requires :activity, type: Hash do
            requires :workup, type: Hash, desc: 'Generic Activity workup hash bearing the details.'
            optional :reaction_process_vessel, type: Hash, desc: 'Optional vessel associated with this activity.'
          end
        end

        desc 'Update a ReactionProcessActivity.'
        put do
          Usecases::ReactionProcessEditor::ReactionProcessActivities::Update.execute!(
            activity: @activity, activity_params: permitted_params[:activity],
          )

          status 204
        end

        desc 'Create and append consuming actions for the fractions' \
             'manually grouped from a chromatography automation result.'
        put :create_fraction_consuming_activities do
          fractions_params = params[:fractions]
          @activity.fractions.destroy_all

          fractions_params.each_with_index do |fraction_params, index|
            ::Usecases::ReactionProcessEditor::ReactionProcessSteps::AppendFractionConsumingActivity
              .execute!(parent_action: @activity, index: index, fraction_params: fraction_params)
          end

          @activity.workup['automation_control'] ||= {}
          @activity.workup['automation_control']['status'] = 'HALT_RESOLVED_NEEDS_CONFIRMATION'
          @activity.save

          status 201
        end

        desc 'Update Position of a ReactionProcessActivity'
        put :update_position do
          Usecases::ReactionProcessEditor::ReactionProcessActivities::UpdatePosition.execute!(
            activity: @activity,
            position: params[:position],
          )
        end

        desc 'Delete a ReactionProcessActivity'
        delete do
          Usecases::ReactionProcessEditor::ReactionProcessActivities::Destroy.execute!(activity: @activity)

          status 204
        end
      end
    end
  end
end
