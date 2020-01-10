class CreateEquipment < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment do |t|
      t.integer :character_id
      t.integer :slot
      t.string :item_uid
      t.string :ench_uid
      t.timestamps
    end
    add_index :equipment, :character_id
  end
end
