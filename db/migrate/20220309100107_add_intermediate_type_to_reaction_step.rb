class AddIntermediateTypeToReactionStep < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions_samples, :reaction_step, :integer
    add_column :reactions_samples, :intermediate_type, :string
  end
end
