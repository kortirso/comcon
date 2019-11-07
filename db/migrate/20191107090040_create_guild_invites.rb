class CreateGuildInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :guild_invites do |t|
      t.integer :guild_id
      t.integer :character_id
      t.boolean :from_guild, null: false, default: false
      t.timestamps
    end
    add_index :guild_invites, [:guild_id, :character_id, :from_guild], unique: true
  end
end
