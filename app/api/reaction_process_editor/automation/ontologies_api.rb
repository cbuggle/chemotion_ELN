# frozen_string_literal: true

module ReactionProcessEditor
  module Automation
    class OntologiesAPI < Grape::API
      helpers StrongParamsHelpers

      namespace :ontologies do
        route_param :id, format: :uuid do
          before do
            @ontology = ReactionProcessEditor::Ontology.find_by(id: params[:id])
            error!('404 Not Found', 404) unless @ontology
            error!('404 Not Found', 404) unless current_user.is_a?(ReactionProcessEditor::ApiUser)
          end

          params do
            requires :ontology_device_methods, type: Array do
              optional :id, type: String
              requires :label, type: String
              optional :detectors, type: Array
              optional :mobile_phase, type: Array
              optional :stationary_phase, type: Array
              optional :default_inject_volume, type: Hash
              optional :description, type: String
              optional :steps, type: Array
              optional :active, type: Boolean
            end
          end
          desc 'Set OntologyDeviceMethods for an Ontology'
          put :ontology_device_methods do
            methods_params = permitted_params[:ontology_device_methods].map { |method| method.to_h.symbolize_keys }

            ActiveRecord::Base.transaction do
              methods = methods_params.map do |method_params|
                method = if method_params[:id].present?
                           @ontology.device_methods.find_by(id: method_params.delete(:id)) ||
                             error!('404 Not Found', 404)
                         else
                           @ontology.device_methods.build
                         end

                method.assign_attributes(method_params)
                method.save!
                method
              end

              method_ids = methods.map(&:id)
              @ontology.device_methods.where.not(id: method_ids).update_all(active: false)
            end

            status 204
          rescue ActiveRecord::RecordInvalid => e
            status 422
            { errors: e.record.errors.messages }
          end
        end
      end
    end
  end
end
