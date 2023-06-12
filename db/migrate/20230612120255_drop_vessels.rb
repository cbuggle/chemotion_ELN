class DropVessels < ActiveRecord::Migration[6.1]
  def up
    drop_table :vessels
    drop_table :vessel_preparations
    drop_table :reaction_process_vessels
    drop_table :user_vessels

    remove_column :reaction_process_steps, :vessel_preparations
  end

  def down
  end
end
