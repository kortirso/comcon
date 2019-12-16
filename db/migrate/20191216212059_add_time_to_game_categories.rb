class AddTimeToGameCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :game_item_categories, :updated_at, :datetime
  end
end
