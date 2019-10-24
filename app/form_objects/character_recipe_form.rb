# Represents form object for CharacterRecipe model
class CharacterRecipeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :recipe, Recipe
  attribute :character_profession, CharacterProfession

  validates :recipe, :character_profession, presence: true

  attr_reader :character_recipe

  def persist?
    return false unless valid?
    return false if exists?
    @character_recipe = CharacterRecipe.new
    @character_recipe.attributes = attributes.except(:id)
    @character_recipe.save
    true
  end

  private

  def exists?
    CharacterRecipe.find_by(recipe: recipe, character_profession: character_profession).present?
  end
end
