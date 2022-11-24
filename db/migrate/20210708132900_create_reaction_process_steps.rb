# frozen_string_literal: true

class CreateReactionProcessSteps < ActiveRecord::Migration[4.2]
  def change
    create_table :reaction_process_steps, id: :uuid do |t|
      t.uuid :reaction_process_id
      t.uuid :reaction_process_vessel_id
      t.string :name
      t.string :vessel_preparations
      t.integer :position

      t.boolean :locked
      t.integer :duration
      t.integer :start_time

      t.timestamps null: false
    end
  end
end
