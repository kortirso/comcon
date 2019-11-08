# Service for uploading existed for user recipes
class CharacterRecipesUpload
  def self.call(character_id:, profession_id:, value:)
    values = value.split(';')
    locale = values.shift[0..1] == 'ru' ? 'ru' : 'en'
    return nil if values.empty?
    # locale - locale for name search
    # values - array of recipe's names
    recipes = Recipe.where(profession_id: profession_id).to_a
    character_profession = CharacterProfession.find_by(character_id: character_id, profession_id: profession_id)
    return nil if character_profession.nil?

    until values.empty?
      recipe_name = values.shift
      recipe = recipes.detect { |elem| elem.name[locale] == recipe_name }
      # if recipe with such name does not exists
      next if recipe.nil?
      # find or create new character_recipe
      character_recipe_form = CharacterRecipeForm.new(recipe: recipe, character_profession: character_profession)
      character_recipe_form.persist?
    end
    true
  rescue
    nil
  end
end
