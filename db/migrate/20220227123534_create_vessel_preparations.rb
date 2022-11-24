class CreateVesselPreparations < ActiveRecord::Migration[5.2]
  def change
    create_table :vessel_preparations, id: :uuid  do |t|
      t.uuid :vessel_id
      t.string :details
      t.string :preparation_type
      t.string :medium_type

      t.timestamps null: false
    end
  end
end
