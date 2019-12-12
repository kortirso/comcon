class CreateGameItems < ActiveRecord::Migration[5.2]
  def change
    create_table :game_item_categories do |t|
      t.integer :uid
      t.jsonb :name, null: false, default: { en: '', ru: '' }
    end
    add_index :game_item_categories, :uid
    add_index :game_item_categories, :name, using: :gin

    create_table :game_item_subcategories do |t|
      t.integer :uid
      t.jsonb :name, null: false, default: { en: '', ru: '' }
    end
    add_index :game_item_subcategories, :uid
    add_index :game_item_subcategories, :name, using: :gin

    create_table :game_item_qualities do |t|
      t.integer :uid
      t.jsonb :name, null: false, default: { en: '', ru: '' }
    end
    add_index :game_item_qualities, :uid
    add_index :game_item_qualities, :name, using: :gin

    create_table :game_items do |t|
      t.integer :item_uid
      t.integer :game_item_category_id
      t.integer :game_item_subcategory_id
      t.integer :game_item_quality_id
      t.integer :level
      t.string :icon_name
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.timestamps
    end
    add_index :game_items, :name, using: :gin
    add_index :game_items, :item_uid
    add_index :game_items, :game_item_category_id
    add_index :game_items, :game_item_subcategory_id
    add_index :game_items, :game_item_quality_id
  end
end
