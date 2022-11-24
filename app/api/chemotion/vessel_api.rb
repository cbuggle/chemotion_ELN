# frozen_string_literal: true

module Chemotion
  class VesselAPI < Grape::API
    helpers StrongParamsHelpers

    namespace :vessels do
      desc 'Index of Vessel for given current User.'
      get do
        present current_user.vessels, root: :vessels
      end

      desc 'Create a Vessel and optionally assign it to a ReactionProcess'
      params do
        requires :vessel, type: Hash do
          requires :details, type: String, desc: 'Details'
          requires :vessel_type, type: String, desc: 'Vessel Type (enum)'
          requires :volume_amount, type: String, desc: 'Volume Amount'
          requires :volume_unit, type: String, desc: 'Volume Type (enum)'
          requires :environment_type, type: :String, desc: 'Environnent (enum)'
          requires :environment_details, type: String, desc: 'Environment Details'
          requires :material_type, type: String, desc: 'Material (enum)'
          requires :material_details, type: String, desc: 'Material Details'
          requires :automation_type, type: String, desc: 'Automated (enum)'
          requires :preparations, type: String, desc: 'Preparations'
          requires :attachments, type: Array, desc: 'Attachments'
        end
        optional :reaction_process_id
        optional :assign_to_reaction, type: Boolean
      end
      post do
        present Vessel.create_and_assign(params: permitted_params, user: current_user), root: :vessel
      end

      route_param :id do
        desc 'Update a Vessel'
        params do
          requires :vessel, type: Hash do
            optional :details, type: String, desc: 'Details'
            optional :vessel_type, type: String, desc: 'Vessel Type (enum)'
            optional :volume_amount, type: String, desc: 'Volume Amount'
            optional :volume_unit, type: String, desc: 'Volume Type (enum)'
            optional :environment_type, type: :String, desc: 'Environnent (enum)'
            optional :environment_details, type: String, desc: 'Environment Details'
            optional :material_type, type: String, desc: 'Material (enum)'
            optional :material_details, type: String, desc: 'Material Details'
            optional :automation_type, type: String, desc: 'Automated (enum)'
            optional :preparations, type: String, desc: 'Preparations'
            optional :attachments, type: Array, desc: 'Attachments'
          end
        end
        put do
          return if params[:vessel].blank?

          @vessel = Vessel.find_by(id: params[:vessel][:id])

          error!('401 Unauthorized', 401) unless current_user == @vessel.creator
          error!('404 Not Found', 404) unless @vessel
          @vessel.update permitted_params[:vessel]
          present @vessel, root: :vessel
        end
        desc 'Delete a Vessels and unassign it from all Users'
        delete do
          @vessel = Vessel.find_by(id: params[:id])
          error!('404 Not Found', 404) unless @vessel
          error!('401 Unauthorized', 401) unless current_user == @vessel.creator
          @vessel.destroy
        end
      end
    end
  end
end
