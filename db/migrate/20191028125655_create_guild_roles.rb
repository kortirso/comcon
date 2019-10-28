class CreateGuildRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :guild_roles do |t|
      t.integer :guild_id
      t.integer :character_id
      t.string :name
      t.timestamps
    end
    add_index :guild_roles, [:guild_id, :character_id], unique: true
  end
end
