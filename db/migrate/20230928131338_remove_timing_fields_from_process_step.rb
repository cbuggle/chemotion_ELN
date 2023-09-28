class RemoveTimingFieldsFromProcessStep < ActiveRecord::Migration[6.1]
  def change
    remove_column :reaction_process_steps, :start_time, :integer
  end
end
