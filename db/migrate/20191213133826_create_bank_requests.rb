class CreateBankRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_requests do |t|
      t.integer :bank_id
      t.integer :game_item_id
      t.integer :character_id
      t.integer :requested_amount
      t.integer :provided_amount
      t.string :character_name
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :bank_requests, :bank_id
    add_index :bank_requests, :character_id
    add_index :bank_requests, :game_item_id
  end
end
