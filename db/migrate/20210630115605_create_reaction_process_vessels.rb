# frozen_string_literal: true

class CreateReactionProcessVessels < ActiveRecord::Migration[4.2]
  def change
    create_table :reaction_process_vessels, id: :uuid do |t|
      t.uuid :reaction_process_id
      t.uuid :vessel_id

      t.timestamps null: false
    end
  end
end
