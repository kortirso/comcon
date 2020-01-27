class RemoveDungeonAccess < ActiveRecord::Migration[5.2]
  def change
    drop_table :dungeon_accesses
    remove_column :dungeons, :key_access
    remove_column :dungeons, :quest_access
  end
end
