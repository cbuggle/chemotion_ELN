class CreateSamplesPreparations < ActiveRecord::Migration[5.2]
  def change
    create_table :samples_preparations do |t|
      t.integer :sample_id
      t.uuid :reaction_process_id
      t.string :preparations, array: true
      t.string :equipment, array: true
      t.string :details
    end
  end
end
