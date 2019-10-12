class CreateCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :characters do |t|
      t.string :name, null: false, default: ''
      t.integer :level, null: false, default: 60
      t.integer :race_id
      t.integer :character_class_id
      t.integer :user_id
      t.integer :world_id
      t.timestamps
    end
    add_index :characters, :race_id
    add_index :characters, :character_class_id
    add_index :characters, :user_id
    add_index :characters, :world_id
    add_index :characters, :name
  end
end
