# frozen_string_literal: true

module ReactionProcessEditor
  module Automation
    class ClapUploadAPI < Grape::API
      namespace :reaction_processes do
        route_param :id do
          desc 'Export a reaction process as CLAP and upload it to the configured receiver.'
          post 'clap/upload' do
            reaction_process = ::ReactionProcessEditor::ReactionProcess.find(params[:id])
            error!('403 Forbidden', 403) unless reaction_process.creator == current_user

            response = Clap::Uploader.new(reaction_process).call
            status :created
            { uploaded: true, upstream_status: response.code }
          rescue Clap::Uploader::ConfigurationError => e
            error!({ message: e.message }, 503)
          rescue Clap::Uploader::RequestError => e
            error!({ message: e.message }, 502)
          end
        end
      end
    end
  end
end
