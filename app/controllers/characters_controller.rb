class CharactersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update_recipes]
  before_action :find_characters, only: %i[index]
  before_action :find_character_by_slug, only: %i[show edit recipes]
  before_action :find_character, only: %i[destroy update_recipes]
  before_action :find_character_professions, only: %i[show recipes]
  before_action :allow_wowhead_script, only: %i[show]

  def index; end

  def show; end

  def new; end

  def edit; end

  def destroy
    @character.destroy
    redirect_to characters_path, status: 303
  end

  def recipes; end

  def update_recipes
    UpdateCharacterRecipes.call(character_id: @character.id, recipe_params: recipe_params)
    redirect_to characters_path
  end

  private

  def find_characters
    @characters = Character.where(user: Current.user).order(level: :desc).includes(:character_class, :world, :guild, race: :fraction)
  end

  def find_character_by_slug
    @character = Character.find_by(slug: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
  end

  def find_character
    @character = Character.where(user: Current.user).find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
  end

  def find_character_professions
    @character_professions = @character.character_professions.includes(:character_recipes, profession: :recipes).where('professions.recipeable = true').references(:professions)
  end

  def recipe_params
    char_profs = @character.character_professions.includes(:profession).where('professions.recipeable = true').references(:professions)
    h = params[:character].present? && params[:character][:recipes].present? ? params.require(:character).permit(recipes: {}).to_h[:recipes] : {}
    char_profs.each do |profession|
      next if h.key?(profession.id.to_s)
      h[profession.id.to_s] = {}
    end
    h
  end
end
