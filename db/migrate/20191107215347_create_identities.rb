class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities do |t|
      t.integer :user_id
      t.string :provider, null: false
      t.string :uid, null: false
      t.timestamps
    end
    add_index :identities, :user_id
  end
end
