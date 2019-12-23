class CreateCharacterTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :character_transfers do |t|
      t.integer :character_id
      t.integer :race_id
      t.integer :character_class_id
      t.integer :world_id
      t.string :name
      t.timestamps
    end
    add_index :character_transfers, :character_id
    add_index :character_transfers, :race_id
    add_index :character_transfers, :character_class_id
    add_index :character_transfers, :world_id
  end
end
