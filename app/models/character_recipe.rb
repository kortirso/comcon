# frozen_string_literal: true

# Represents recipes that characters have
class CharacterRecipe < ApplicationRecord
  belongs_to :recipe
  belongs_to :character_profession
end
