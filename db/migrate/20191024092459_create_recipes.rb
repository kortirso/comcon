class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.integer :profession_id
      t.integer :skill, null: false, default: 1
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.jsonb :links, null: false, default: { en: '', ru: '' }
      t.timestamps
    end
    add_index :recipes, :profession_id
    add_index :recipes, :name, using: :gin
  end
end
