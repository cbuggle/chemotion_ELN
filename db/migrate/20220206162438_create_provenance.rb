class CreateProvenance < ActiveRecord::Migration[5.2]
  def change
    create_table :provenances, id: :uuid  do |t|
      t.string :reaction_process_id
      t.datetime :starts_at
      t.string :city
      t.string :doi
      t.string :patent
      t.string :publication_url
      t.string :username
      t.string :name
      t.string :orcid
      t.string :organization
      t.string :email

      t.timestamps null: false
    end
  end
end
