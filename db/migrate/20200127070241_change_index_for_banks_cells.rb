class ChangeIndexForBanksCells < ActiveRecord::Migration[5.2]
  def change
    remove_index :static_invites, name: 'index_bank_cells_on_bank_id_and_item_uid'
    add_index :bank_cells, [:bank_id, :item_uid, :bag_number], unique: true
  end
end
