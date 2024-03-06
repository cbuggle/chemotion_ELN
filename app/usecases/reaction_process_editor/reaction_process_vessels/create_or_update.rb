# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessVessels
      class CreateOrUpdate
        def self.execute!(reaction_process_id:, reaction_process_vessel_params:)
          Rails.logger.info('BUGPARAMS')
          Rails.logger.info(reaction_process_vessel_params.to_h)

          reaction_process_vessel = ::ReactionProcessEditor::ReactionProcessVessel.find_or_create_by(
            reaction_process_id: reaction_process_id,
            vessel_id: reaction_process_vessel_params[:vessel_id],
          )

          reaction_process_vessel.update(preparations: reaction_process_vessel_params[:preparations])

          Usecases::ReactionProcessEditor::ReactionProcessVessels::SweepUnused.execute!(
            reaction_process_id: reaction_process_id,
          )

          Rails.logger.info('BUGPARAMS Vessel')
          Rails.logger.info(reaction_process_vessel.inspect)
          reaction_process_vessel
        end
      end
    end
  end
end
