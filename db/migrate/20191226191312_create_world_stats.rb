class CreateWorldStats < ActiveRecord::Migration[5.2]
  def change
    create_table :world_stats do |t|
      t.integer :world_id, null: false, foreign_key: true
      t.integer :characters_count
      t.integer :guilds_count
      t.integer :statics_count
      t.index :world_id, unique: true
    end
  end
end
