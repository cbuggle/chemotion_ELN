# frozen_string_literal: true

module ReactionProcessEditor
  class ReactionProcessesController < ApplicationController
    respond_to :json

    before_action :authenticate_user!

    def ord
      # Note that we have have a Reaction id, not a ReactionProcess id.
      # We mount it to /reaction_processes/:id/ord => ReactionProcessesController#ord for modularity.

      reaction = ReactionProcess.find(params[:id]).reaction
      filename = "#{Date.today.iso8601}-Reaction-#{reaction.id}-#{reaction.short_label}.kit-ord.json"

      reaction_ord = OrdKit::Exporter::ReactionExporter.new(reaction).to_ord

      send_data(reaction_ord.to_json, filename: filename, type: 'application/json')
    rescue StandardError => e
      send_data("#{e.message} #{e.backtrace}", filename: filename)
    end
  end
end
