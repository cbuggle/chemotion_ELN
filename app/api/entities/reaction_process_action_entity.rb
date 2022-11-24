# frozen_string_literal: true

module Entities
  class ReactionProcessActionEntity < ApplicationEntity
    expose(:id, :action_name, :position, :workup,
           :starts_at, :ends_at, :duration, :start_time)

    expose! :sample, using: 'Entities::SampleEntity'
    expose! :medium, using: 'Entities::ReactionMediumEntity'

    private

    def start_time
      object.start_time || 0
    end

    def duration
      object.duration || 0
    end
  end
end
