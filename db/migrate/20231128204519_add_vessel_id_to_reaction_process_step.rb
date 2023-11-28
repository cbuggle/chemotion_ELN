class AddVesselIdToReactionProcessStep < ActiveRecord::Migration[6.1]
  def change
    add_column :reaction_process_steps, :vessel_id, :uuid
  end
end
