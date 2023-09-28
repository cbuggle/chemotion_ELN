class RemoveTimingFieldsFromReactionProcesses < ActiveRecord::Migration[6.1]
  def change
    remove_column :reaction_processes, :starts_at, :datetime
    remove_column :reaction_processes, :duration, :integer
  end
end
