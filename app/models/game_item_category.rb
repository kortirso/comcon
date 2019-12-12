# Represents game item categories
class GameItemCategory < ApplicationRecord
  has_many :game_items, dependent: :destroy
end
