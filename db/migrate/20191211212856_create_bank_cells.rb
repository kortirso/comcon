class CreateBankCells < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_cells do |t|
      t.integer :bank_id
      t.integer :item_uid
      t.integer :amount, null: false, default: 1
      t.timestamps
    end
    add_index :bank_cells, [:bank_id, :item_uid], unique: true
  end
end
