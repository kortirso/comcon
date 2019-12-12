# Represents game items
class GameItem < ApplicationRecord
  belongs_to :game_item_quality
  belongs_to :game_item_category, optional: true
  belongs_to :game_item_subcategory, optional: true
end
