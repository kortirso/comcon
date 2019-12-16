# Represents game items
class GameItem < ApplicationRecord
  belongs_to :game_item_quality
  belongs_to :game_item_category, optional: true, touch: true
  belongs_to :game_item_subcategory, optional: true

  has_many :bank_cells, dependent: :destroy
  has_many :bank_requests, dependent: :destroy
end
