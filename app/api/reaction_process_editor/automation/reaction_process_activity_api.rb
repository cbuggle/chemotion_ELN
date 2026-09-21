# frozen_string_literal: true

module ReactionProcessEditor
  module Automation
    class ReactionProcessActivityAPI < Grape::API
      include Grape::Extensions::Hashie::Mash::ParamBuilder

      helpers StrongParamsHelpers

      rescue_from :all

      namespace :reaction_process_activities do
        route_param :id do
          params do
            requires :response_json
          end

          put :automation_response do
            error!('404 Not Found', 404) unless current_user.is_a?(ReactionProcessEditor::ApiUser)

            @activity = ::ReactionProcessEditor::ReactionProcessActivity.find_by(id: params[:id])

            response_file = params[:response_json].tempfile

            Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationResponse.execute!(
              activity: @activity,
              response_json: response_file,
            )

            status 201
          rescue StandardError
            error!('422 Unprocessable Entity', 422)
          end

          params do
            requires :status
          end

          put :automation_status do
            error!('404 Not Found', 404) unless current_user.is_a?(ReactionProcessEditor::ApiUser)

            @activity = ::ReactionProcessEditor::ReactionProcessActivity.find_by(id: params[:id])

            Usecases::ReactionProcessEditor::ReactionProcessActivities::HandleAutomationStatus.execute!(
              activity: @activity,
              automation_status: params[:status],
            )

            status 204
          rescue StandardError
            error!('422 Unprocessable Entity', 422)
          end
        end
      end
    end
  end
end
