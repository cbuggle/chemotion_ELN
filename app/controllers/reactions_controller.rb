# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :authenticate_user!

  def ord

    reaction = Reaction.find params[:id]
    filename = "#{Date.today.iso8601}-Reaction-#{reaction.id}-#{reaction.short_label}.kit-ord.json"

    reaction_ord = OrdKit::Exporter::ReactionExporter.new(reaction).to_ord

    send_data(reaction_ord.to_json, filename: filename, type: 'application/json')
  rescue StandardError => e
    send_data(  "#{e.message} #{e.backtrace}", filename: filename)
  end
end

