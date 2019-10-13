class AddDungeonToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :dungeon_id, :integer
    add_index :events, :dungeon_id
  end
end
