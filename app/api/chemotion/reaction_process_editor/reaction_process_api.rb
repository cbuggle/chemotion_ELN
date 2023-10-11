# frozen_string_literal: true

module Chemotion
  module ReactionProcessEditor
    class ReactionProcessAPI < Grape::API
      helpers StrongParamsHelpers

      rescue_from :all

      namespace :reactions do
        params do
          requires :id, type: Integer, desc: 'Reaction id'
        end

        route_param :id do
          before do
            @reaction = Reaction.find_by(id: params[:id])
            # TODO: decide which to return
            error!('404 Not Found', 404) unless @reaction
            # error!('401 Unauthorized', 401) unless current_user && @element_policy.read?

            @element_policy = ElementPolicy.new(current_user, @reaction)
            error!('401 Unauthorized', 401) unless current_user && @element_policy.read?
          end

          desc 'Create associated reaction procedure unless existant'
          get :reaction_process do
            # Creating the ReactionProcess if missing sort of violates REST/CRUD principles.
            # However substantially it is a GET. We use it only to fetch data (never manipulate).
            reaction_process = ::ReactionProcessEditor::ReactionProcess.find_or_create_by(reaction_id: params[:id])

            present reaction_process, with: Entities::ReactionProcessEditor::ReactionProcessEntity,
                                      root: :reaction_process
          end
        end
      end

      namespace :reaction_processes do
        get do
          reactions = if params[:collection_id]
                        begin
                          Collection.belongs_to_or_shared_by(current_user.id,
                                                             current_user.group_ids).find(params[:collection_id]).reactions
                        rescue ActiveRecord::RecordNotFound
                          Reaction.none
                        end
                      else
                        current_user.collections.map(&:reactions).flatten.uniq
                      end.sort_by(&:id)

          present reactions, with: Entities::ReactionProcessEditor::ReactionEntity, root: :reactions
        end

        desc 'get options for collection Select.'
        get :collection_select_options do
          { collection_select_options:
          current_user.collections.map { |collection| { value: collection.id, label: collection.label } } }
        end

        namespace :user_default_conditions do
          desc 'Update the Default Conditions of the User.'
          params do
            requires :default_conditions, type: Hash, desc: 'The Default Conditions of the User.'
          end
          put do
            reaction_process_defaults = ::ReactionProcessEditor::ReactionProcessDefaults
                                        .find_or_initialize_by(user: current_user)
            reaction_process_defaults.update permitted_params
          end
        end

        desc 'get default_conditions of a User.'
        get :default_conditions do
          {
            global: ::ReactionProcessEditor::SelectOptions.instance.global_default_conditions,
            user: current_user.reaction_process_defaults&.default_conditions.to_h,
            conditions_equipment_options:
             ::ReactionProcessEditor::SelectOptions.instance.action_type_equipment['CONDITION'],
          }
        end

        route_param :id do
          before do
            @reaction_process = ::ReactionProcessEditor::ReactionProcess.find(params[:id])
            error!('404 Not Found', 404) unless @reaction_process
          end

          desc 'Get a ReactionProcess'
          get do
            present @reaction_process,
                    with: Entities::ReactionProcessEditor::ReactionProcessEditor::ReactionProcessEntity,
                    root: :reaction_process
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

          namespace :reaction_default_conditions do
            desc 'Update the Default Conditions of the Reaction.'
            params do
              requires :default_conditions, type: Hash, desc: 'The Default Conditions of the Reaction.'
            end
            put do
              @reaction_process.update permitted_params
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
              sample_preparation ||= @reaction_process.samples_preparations
                                                      .find_or_initialize_by(sample_id: params[:sample_preparation][:sample_id])
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
            params do
              requires :reaction_process_step, type: Hash do
                optional :name
                optional :locked
              end
            end

            post do
              new_step = @reaction_process.reaction_process_steps.create(
                position: @reaction_process.reaction_process_steps.count,
              )

              new_step.update params[:reaction_process_step]
              present new_step, with: Entities::ReactionProcessEditor::ReactionProcessStepEntity,
                                root: :reaction_process_step
            end
          end

          # TODO: reinsert once Vessel model is in main.
          # namespace :vessels do
          #   route_param :vessel_id do
          #     desc 'Add the Vessel to the ReactionProcess'
          #     put do
          #       vessel = Vessel.find params[:vessel_id]
          #       error!('404 Not Found', 404) unless vessel
          #       if @reaction_process
          #         ReactionProcessVessel.find_or_create_by(reaction_process: @reaction_process,
          #                                                 vessel: vessel)
          #       end
          #     end

          #     desc 'Delete a Vessels from the ReactionProcess'
          #     delete do
          #       @vessel = @reaction_process.vessels.find_by(id: params[:vessel_id])
          #       error!('401 Unauthorized', 401) unless @reaction_process.reaction.creator == current_user
          #       error!('404 Not Found', 404) unless @vessel

          #       @reaction_process.reaction_process_vessel.where(vessel_id: params[:vessel_id]).delete_all
          #     end
          #   end
          # end
        end
      end
    end
  end
end
