# Represents recipes for professions
class Recipe < ApplicationRecord
  belongs_to :profession

  has_many :character_recipes, dependent: :destroy
  has_many :character_profession, through: :character_recipes

  after_save ThinkingSphinx::RealTime.callback_for(:recipe)

  def self.cache_key(recipes)
    {
      serializer: 'recipes',
      stat_record: recipes.maximum(:updated_at)
    }
  end

  def name_en
    name['en']
  end

  def name_ru
    name['ru']
  end
end
