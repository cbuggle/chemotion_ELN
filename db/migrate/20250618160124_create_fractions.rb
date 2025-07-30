class CreateFractions < ActiveRecord::Migration[6.1]
  def change
    create_table :fractions, id: :uuid do |t|
      t.integer :position
      t.uuid :reaction_process_activity_id
      t.uuid :followup_activity_id
      t.string :vials, default: [], array: true

      t.timestamps
    end
  end
end
