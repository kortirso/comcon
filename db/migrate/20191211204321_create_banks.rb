class CreateBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :banks do |t|
      t.integer :guild_id
      t.string :name
      t.integer :coins, null: false, default: 0
      t.timestamps
    end
    add_index :banks, :guild_id
  end
end
