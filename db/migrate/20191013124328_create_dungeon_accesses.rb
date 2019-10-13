class CreateDungeonAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :dungeon_accesses do |t|
      t.integer :character_id
      t.integer :dungeon_id
      t.timestamps
    end
    add_index :dungeon_accesses, [:character_id, :dungeon_id], unique: true
  end
end
