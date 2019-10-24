# Represents recipes for professions
class Recipe < ApplicationRecord
  belongs_to :profession

  has_many :character_recipes, dependent: :destroy
end
