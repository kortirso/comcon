# frozen_string_literal: true

# Represents game item subcategories
class GameItemSubcategory < ApplicationRecord
  has_many :game_items, dependent: :destroy

  def to_hash
    {
      id.to_s => {
        'name' => name
      }
    }
  end
end
