class AddDefaultConditionsToReactionProcesses < ActiveRecord::Migration[6.1]
  def change
    add_column :reaction_processes, :default_conditions, :jsonb
  end
end
