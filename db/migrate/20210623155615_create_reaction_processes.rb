# frozen_string_literal: true

class CreateReactionProcesses < ActiveRecord::Migration[4.2]
  def change
    create_table :reaction_processes, id: :uuid do |t|
      t.integer :reaction_id

      t.integer :duration
      t.datetime :starts_at

      t.timestamps null: false
    end
  end
end
