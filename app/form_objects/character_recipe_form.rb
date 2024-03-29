# frozen_string_literal: true

# Represents form object for CharacterRecipe model
class CharacterRecipeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :recipe, Recipe
  attribute :character_profession, CharacterProfession

  validates :recipe, :character_profession, presence: true
  validate :exists?

  attr_reader :character_recipe

  def persist?
    return false unless valid?

    @character_recipe = CharacterRecipe.new
    @character_recipe.attributes = attributes
    @character_recipe.save
    true
  end

  private

  def exists?
    return unless CharacterRecipe.exists?(recipe: recipe, character_profession: character_profession)

    errors.add(:character_recipe, message: 'already exists')
  end
end
