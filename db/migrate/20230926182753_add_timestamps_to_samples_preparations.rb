class AddTimestampsToSamplesPreparations < ActiveRecord::Migration[6.1]
  def change
    add_timestamps(:samples_preparations, null: true)
  end
end
