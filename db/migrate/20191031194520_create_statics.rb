class CreateStatics < ActiveRecord::Migration[5.2]
  def change
    create_table :statics do |t|
      t.integer :guild_id
      t.string :name
      t.timestamps
    end
    add_index :statics, [:guild_id, :name], unique: true
  end
end
