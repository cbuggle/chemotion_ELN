# frozen_string_literal: true

module Usecases
  module ReactionProcessEditor
    module ReactionProcessVessels
      class SweepUnused
        def self.execute!(reaction_process_id:)
          persisted_vessel_ids = ::ReactionProcessEditor::ReactionProcessVessel
                                 .where(reaction_process_id: reaction_process_id).pluck(:id)

          current_vessel_ids = ::ReactionProcessEditor::ReactionProcessStep
                               .where(reaction_process_id: reaction_process_id).pluck(:reaction_process_vessel_id).uniq

          obsolete_vessel_ids = persisted_vessel_ids - current_vessel_ids

          ::ReactionProcessEditor::ReactionProcessVessel.where(id: obsolete_vessel_ids).destroy_all
        end
      end
    end
  end
end
