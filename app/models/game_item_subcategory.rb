# Represents game item subcategories
class GameItemSubcategory < ApplicationRecord
  has_many :game_items, dependent: :destroy
end
