class CreateUserVessels < ActiveRecord::Migration[5.2]
  def up
    create_table :user_vessels, id: :uuid do |t|
      enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
      t.integer :user_id
      t.uuid :vessel_id

      t.timestamps null: false
    end
  end

  def down
    drop_table :user_vessels
  end
end
