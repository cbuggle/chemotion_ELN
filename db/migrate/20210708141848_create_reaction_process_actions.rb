# frozen_string_literal: true

class CreateReactionProcessActions < ActiveRecord::Migration[4.2]
  def change
    create_table :reaction_process_actions, id: :uuid do |t|
      t.uuid :reaction_process_step_id

      t.string :action_name
      t.integer :position

      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :duration
      t.integer :start_time

      t.json :workup

      t.timestamps null: false
    end
  end
end
