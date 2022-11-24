# frozen_string_literal: true

class CreateVessels < ActiveRecord::Migration[4.2]
  def change
    create_table :vessels, id: :uuid do |t|
      t.uuid "reaction_process_id"
      t.string "name"
      t.string "details"
      t.string "vessel_type"
      t.string "volume_unit"
      t.string "environment_type"
      t.string "material_type"
      t.string "automation_type"
      t.string "environment_details"
      t.string "material_details"
      t.string "volume_amount"
      t.string "preparations"
      t.string "attachment_details"
      t.string "attachments", array: true

      t.timestamps
    end
  end
end
