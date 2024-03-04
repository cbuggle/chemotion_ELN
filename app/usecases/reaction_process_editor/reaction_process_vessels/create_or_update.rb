# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessVessels
      class CreateOrUpdate
        def self.execute!(reaction_process_id:, vessel_id:, reaction_process_vessel_params:)
          return unless vessel_id

          reaction_process_vessel = ::ReactionProcessEditor::ReactionProcessVessel.find_or_create_by(
            reaction_process_id: reaction_process_id,
            vessel_id: vessel_id,
          )

          reaction_process_vessel.update(preparations: reaction_process_vessel_params[:preparations])

          Usecases::ReactionProcessEditor::ReactionProcessVessels::Calculate.execute!(
            reaction_process_id: reaction_process_id,
          )
        end
      end
    end
  end
end
