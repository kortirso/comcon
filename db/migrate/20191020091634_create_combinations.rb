class CreateCombinations < ActiveRecord::Migration[5.2]
  def change
    create_table :combinations do |t|
      t.integer :character_class_id
      t.integer :combinateable_id
      t.string :combinateable_type
      t.timestamps
    end
    add_index :combinations, :character_class_id
    add_index :combinations, [:combinateable_id, :combinateable_type]
  end
end
