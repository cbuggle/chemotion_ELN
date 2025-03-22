# frozen_string_literal: true

module ReactionProcessEditor
  class ReactionProcessActivityAPI < Grape::API
    include Grape::Extensions::Hashie::Mash::ParamBuilder

    helpers StrongParamsHelpers

    # rescue_from :all

    namespace :reaction_process_activities do
      route_param :id do
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
          present Usecases::ReactionProcessEditor::ReactionProcessActivities::Update.execute!(
            activity: @activity, activity_params: permitted_params[:activity],
          ), with: Entities::ReactionProcessEditor::ReactionProcessActivityEntity, root: :reaction_process_activity
        end

        desc 'Create an Evaporation appended to the ReactionProcessActivity.'
        put :append_evaporation do
          Rails.logger.info("evaporation_params")
          Rails.logger.info(params)

          evaporation_params = {
            'activity_name': 'EVAPORATION',
            'workup': { 'vials': params[:evaporation]['vials'], 'vessel': params[:evaporation]['vessel'],
            'reaction_process_vessel': params[:evaporation][:vessel] }
        }.stringify_keys

          evaporation = Usecases::ReactionProcessEditor::ReactionProcessSteps::AppendActivity
                        .execute!(reaction_process_step: @activity.reaction_process_step,
                                  activity_params: evaporation_params,
                                  position: @activity.position + 1)

          present evaporation, with: Entities::ReactionProcessEditor::ReactionProcessActivityEntity, root: :reaction_process_activity
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
        end
      end

      route_param :id do
        put :automation_response do
          raise "AUTHENTICATION FAILURE" unless current_user.is_a?(ReactionProcessEditor::ApiUser)

           @activity = ::ReactionProcessEditor::ReactionProcessActivity.find_by(id: params[:id])

          response_file = params[:response_csv].tempfile

          Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationResponse.execute!(
            activity: @activity,
            response_csv: response_file,
          )
        end
      end
    end
  end
end
