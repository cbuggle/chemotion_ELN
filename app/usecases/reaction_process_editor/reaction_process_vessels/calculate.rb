# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessVessels
      class Calculate
        def self.execute!(reaction_process_id:)
          persisted_vessel_ids = ::ReactionProcessEditor::ReactionProcessVessel
                                 .where(reaction_process_id: reaction_process_id).pluck(:vessel_id)
          current_vessel_ids = ::ReactionProcessEditor::ReactionProcessStep
                               .where(reaction_process_id: reaction_process_id).pluck(:vessel_id).uniq

          current_vessel_ids.each do |current_vessel_id|
            ::ReactionProcessEditor::ReactionProcessVessel.find_or_create_by(reaction_process_id: reaction_process_id,
                                                                             vessel_id: current_vessel_id)
          end

          obsolete_vessel_ids = persisted_vessel_ids - current_vessel_ids

          ::ReactionProcessEditor::ReactionProcessVessel.where(
            reaction_process_id: reaction_process_id, vessel_id: obsolete_vessel_ids,
          ).destroy_all
        end
      end
    end
  end
end
