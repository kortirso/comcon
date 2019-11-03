class CreateStaticMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :static_members do |t|
      t.integer :static_id
      t.integer :character_id
      t.timestamps
    end
    add_index :static_members, [:static_id, :character_id], unique: true
  end
end
