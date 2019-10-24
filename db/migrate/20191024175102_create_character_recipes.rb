class CreateCharacterRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :character_recipes do |t|
      t.integer :recipe_id
      t.integer :character_profession_id
      t.timestamps
    end
    add_index :character_recipes, [:recipe_id, :character_profession_id], unique: true, name: 'character_recipes_index'
  end
end
