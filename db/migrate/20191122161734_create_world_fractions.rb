class CreateWorldFractions < ActiveRecord::Migration[5.2]
  def change
    create_table :world_fractions do |t|
      t.integer :world_id
      t.integer :fraction_id
      t.timestamps
    end
    add_index :world_fractions, [:world_id, :fraction_id]

    add_column :events, :world_fraction_id, :integer
    add_index :events, :world_fraction_id

    add_column :characters, :world_fraction_id, :integer
    add_index :characters, :world_fraction_id

    add_column :guilds, :world_fraction_id, :integer
    add_index :guilds, :world_fraction_id

    add_column :statics, :world_fraction_id, :integer
    add_index :statics, :world_fraction_id
  end
end
