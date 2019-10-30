# Represents recipes for professions
class Recipe < ApplicationRecord
  belongs_to :profession

  has_many :character_recipes, dependent: :destroy

  def self.cache_key(recipes)
    {
      serializer: 'recipes',
      stat_record: recipes.maximum(:updated_at)
    }
  end
end
