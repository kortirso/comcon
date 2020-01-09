# Represents equipment of character
class Equipment < ApplicationRecord
  belongs_to :character
  belongs_to :game_item, optional: true

  scope :empty, -> { where game_item_id: nil }
end
