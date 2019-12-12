class AddGameItemToBankCells < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_cells, :game_item_id, :integer
    add_index :bank_cells, :game_item_id
  end
end
