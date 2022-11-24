# frozen_string_literal: true

module Chemotion
  class ReactionProcessAPI < Grape::API
    helpers StrongParamsHelpers

    namespace :reaction_process do
      route_param :id do
        before do
          @reaction_process = ReactionProcess.find(params[:id])
          error!('404 Not Found', 404) unless @reaction_process
        end

        desc 'Get a ReactionProcess'
        get do
          present @reaction_process, with: Entities::ReactionProcessEntity, root: :reaction_process
        end

        namespace :provenance do
          desc 'Update the Provenance'
          params do
            requires :provenance, type: Hash, desc: 'The Provenance of the reaction.' do
              optional :starts_at, type: String
              optional :name, type: String
              optional :username, type: String
              optional :email, type: String
              optional :city, type: String
              optional :organization, type: String
              optional :patent, type: String
              optional :orcid, type: String
              optional :doi, type: String
              optional :publication_url, type: String
            end
          end
          put do
            provenance = @reaction_process.provenance || @reaction_process.build_provenance
            provenance.update permitted_params[:provenance]
          end
        end

        namespace :samples_preparations do
          desc 'Update or Create a Sample Preparation'
          params do
            requires :sample_preparation, type: Hash, desc: 'The sample preparation to create/update.' do
              requires :sample_id, type: String
              optional :equipment, type: Array[String]
              optional :preparations, type: Array[String]
              optional :details
            end
          end
          put do
            sample_preparation = @reaction_process.samples_preparations.find_by(id: params[:sample_preparation][:id])
            sample_preparation ||= @reaction_process.samples_preparations.find_or_initialize_by(sample_id: params[:sample_preparation][:sample_id])
            sample_preparation.update(permitted_params[:sample_preparation])
          end

          route_param :sample_preparation_id do
            desc 'Delete a Sample preparation'
            delete do
              @sample_preparation = @reaction_process.samples_preparations.find_by(id: params[:sample_preparation_id])
              error!('401 Unauthorized', 401) unless @reaction_process.reaction.creator == current_user
              error!('404 Not Found', 404) unless @sample_preparation

              @sample_preparation.destroy
            end
          end
        end

        namespace :reaction_process_steps do
          desc 'Create an associated ReactionProcessStep'
          post do
            new_step = @reaction_process.reaction_process_steps.create(
              position: @reaction_process.reaction_process_steps.count,
            )

            new_step.update(start_time: @reaction_process.duration)
            present new_step, with: Entities::ReactionProcessStepEntity, root: :reaction_process_step
          end
        end

        namespace :vessels do
          route_param :vessel_id do
            desc 'Add the Vessel to the ReactionProcess'
            put do
              vessel = Vessel.find params[:vessel_id]
              error!('404 Not Found', 404) unless vessel
              if @reaction_process
                ReactionProcessVessel.find_or_create_by(reaction_process: @reaction_process,
                                                          vessel: vessel)
              end
            end

            desc 'Delete a Vessels from the ReactionProcess'
            delete do
              @vessel = @reaction_process.vessels.find_by(id: params[:vessel_id])
              error!('401 Unauthorized', 401) unless @reaction_process.reaction.creator == current_user
              error!('404 Not Found', 404) unless @vessel

              @reaction_process.reaction_process_vessel.where(vessel_id: params[:vessel_id]).delete_all
            end
          end
        end
      end
    end
  end
end
