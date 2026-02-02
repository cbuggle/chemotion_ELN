class AddAutomationToReactionProcessSteps < ActiveRecord::Migration[6.1]
  def up
    add_column :reaction_process_steps, :automation_control, :jsonb
  end
end
