class AddTimestampsToReactionsSamples < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :reactions_samples, null: true
    change_column_null(:reactions_samples, :created_at, false, Time.zone.now)
    change_column_null(:reactions_samples, :created_at, false, Time.zone.now)
  end
end
