class AddItemLevelToCharacters < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :item_level, :integer, null: false, default: 0
  end
end
