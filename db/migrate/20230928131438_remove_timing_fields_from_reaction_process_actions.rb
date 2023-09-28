class RemoveTimingFieldsFromReactionProcessActions < ActiveRecord::Migration[6.1]
  def change
    remove_column :reaction_process_actions, :starts_at, :datetime
    remove_column :reaction_process_actions, :ends_at, :datetime
    remove_column :reaction_process_actions, :start_time, :integer
    remove_column :reaction_process_actions, :duration, :integer
  end
end
