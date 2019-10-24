# Update CharacterRecipes
class UpdateCharacterRecipes
  include Interactor

  # required context
  # context.character_id
  # context.recipe_params
  def call
    context.recipe_params.each do |character_profession_id, recipes|
      character_profession = CharacterProfession.find_by(id: character_profession_id)
      next if character_profession.nil?

      existed_character_recipes = CharacterRecipe.where(character_profession_id: character_profession_id)
      entry_ids = recipes.keys(&:to_i)

      # check removed recipes
      existed_character_recipes.each do |existed_character_recipe|
        next if entry_ids.include?(existed_character_recipe.recipe_id)
        existed_character_recipe.destroy
      end

      # check added recipes
      recipe_ids = existed_character_recipes.pluck(:recipe_id)
      entry_ids.each do |entry_id|
        next if recipe_ids.include?(entry_id)
        recipe = Recipe.find_by(id: entry_id)
        next if recipe.nil?
        character_recipe_form = CharacterRecipeForm.new(recipe: recipe, character_profession: character_profession)
        character_recipe_form.persist?
      end
    end
  end
end
