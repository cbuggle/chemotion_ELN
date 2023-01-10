# frozen_string_literal: true

module Chemotion
  class ReactionProcessStepAPI < Grape::API
    helpers StrongParamsHelpers
    include Grape::Extensions::Hashie::Mash::ParamBuilder

    namespace :reaction_process_steps do
      route_param :id do
        before do
          @reaction_process_step = ReactionProcessStep.find_by(id: params[:id])
          error!('404 Not Found', 404) unless @reaction_process_step
        end

        desc 'Get a ReactionProcessStep'
        get do
          present @reaction_process_step, with: Entities::ReactionProcessStepEntity, root: :reaction_process_step
        end

        desc 'Update ReactionProcessStep'
        params do
          requires :reaction_process_step, type: Hash do
            optional :name
            optional :locked
          end
        end

        put do
          @reaction_process_step.update permitted_params[:reaction_process_step]
          present @reaction_process_step, with: Entities::ReactionProcessStepEntity, root: :reaction_process_step
        end

        desc 'Destroy a ReactionProcessStep'
        delete do
          @reaction_process_step.destroy_from_reaction_process
        end

        namespace :actions do
          params do
            requires :action, type: Hash do
              requires :action_name, type: String, desc: 'Name of the Action described'
              requires :workup, type: Hash, desc: 'Custom Action Parameters'
            end
          end

          desc 'Add a ReactionProcessAction'
          post do
            action = @reaction_process_step.append_action permitted_params[:action]
            if action.valid?
              status 201
              present action, with: Entities::ReactionProcessActionEntity, root: :reaction_process_action
            else
              status 422
              action.errors
            end
          end
        end

        namespace :vessel do
          desc 'Set the Vessel'
          put do
            if params[:vessel].blank?
              @reaction_process_step.set_vessel nil
            else
              vessel = Vessel.find params[:vessel][:id]
              error!('404 Not Found', 404) unless vessel

              @reaction_process_step.set_vessel vessel
            end
          end
        end

        desc 'Toggle lock status'
        put :toggle_locked do
          @reaction_process_step.toggle_locked
          @reaction_process_step
        end
      end
    end
  end
end
