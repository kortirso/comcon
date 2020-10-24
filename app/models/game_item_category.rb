# frozen_string_literal: true

# Represents game item categories
class GameItemCategory < ApplicationRecord
  has_many :game_items, dependent: :destroy
  has_many :game_item_subcategories, through: :game_items

  def self.cache_key(game_item_categories)
    {
      serializer:  'game_item_categories',
      stat_record: game_item_categories.maximum(:updated_at)
    }
  end

  def self.dependencies
    GameItemCategory.order(id: :asc).includes(:game_item_subcategories).inject({}) { |game_item_categories, game_item_category| game_item_categories.merge(game_item_category.to_hash) }
  end

  def to_hash
    {
      id.to_s => {
        'name'          => name,
        'subcategories' => game_item_subcategories.order(id: :asc).inject({}) do |game_item_subcategories, game_item_subcategory|
          game_item_subcategories.merge(game_item_subcategory.to_hash)
        end
      }
    }
  end
end
