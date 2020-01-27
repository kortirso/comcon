class AddBagNumberToBankCells < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_cells, :bag_number, :integer, default: 0
  end
end
