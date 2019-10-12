class CreateGuilds < ActiveRecord::Migration[5.2]
  def change
    create_table :guilds do |t|
      t.string :name, null: false, default: ''
      t.integer :world_id
      t.timestamps
    end
    add_index :guilds, :name
    add_index :guilds, :world_id

    add_column :characters, :guild_id, :integer
    add_index :characters, :guild_id
  end
end
