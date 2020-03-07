# frozen_string_literal: true

# Represents professions selected by characters
class CharacterProfession < ApplicationRecord
  belongs_to :character
  belongs_to :profession

  has_many :character_recipes, dependent: :destroy
  has_many :recipes, through: :character_recipes
end
