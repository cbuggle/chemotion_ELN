class CreateMedia < ActiveRecord::Migration[4.2]
  def change
    create_table :media, id: :uuid do |t|
      t.string :type
      t.string :sum_formula
      t.string :sample_name
      t.string :molecule_name

      t.timestamps null: false
    end
  end
end
