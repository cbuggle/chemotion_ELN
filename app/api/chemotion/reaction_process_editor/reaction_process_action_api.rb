# frozen_string_literal: true

module Chemotion
  module ReactionProcessEditor
    class ReactionProcessActionAPI < Grape::API
      include Grape::Extensions::Hashie::Mash::ParamBuilder

      helpers StrongParamsHelpers

      # rescue_from :all

      namespace :reaction_process_actions do
        route_param :id do
          before do
            @action = ::ReactionProcessEditor::ReactionProcessAction.find_by(id: params[:id])
            error!('404 Not Found', 404) unless @action
          end

          params do
            requires :action, type: Hash do
              requires :workup, type: Hash, desc: 'Generic action params '
            end
          end

          desc 'Update a ReactionProcessAction'
          put do
            @action.update_by_params permitted_params[:action]
            present @action, with: Entities::ReactionProcessEditor::ReactionProcessActionEntity,
                             root: :reaction_process_action
          end

          desc 'Update Position of a ReactionProcessAction'
          put :update_position do
            @action.update_position(params[:position])
          end

          desc 'Delete a ReactionProcessAction'
          delete do
            @action.delete_from_reaction_process_step
          end
        end
      end
    end
  end
end
