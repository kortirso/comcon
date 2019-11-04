class CreateStaticInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :static_invites do |t|
      t.integer :static_id
      t.integer :character_id
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :static_invites, [:static_id, :character_id], unique: true
    add_index :static_invites, :status
  end
end
