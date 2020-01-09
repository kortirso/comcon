class AddGameItemToEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment, :game_item_id, :integer
    add_index :equipment, :game_item_id
  end
end
