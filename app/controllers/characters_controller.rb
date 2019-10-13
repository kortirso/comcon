class CharactersController < ApplicationController
  before_action :find_characters, only: %i[index]
  before_action :find_character, only: %i[edit update destroy]
  before_action :find_selectors, only: %i[new edit]

  def index; end

  def new; end

  def create
    character_form = CharacterForm.new(character_params)
    if character_form.persist?
      CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
      redirect_to characters_path
    else
      find_selectors
      render :new
    end
  end

  def edit; end

  def update
    character_form = CharacterForm.new(@character.attributes.merge(character_params))
    if character_form.persist?
      CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
      redirect_to characters_path
    else
      find_selectors
      render :edit
    end
  end

  def destroy
    @character.destroy
    redirect_to characters_path, status: 303
  end

  private

  def find_characters
    @characters = Character.where(user: Current.user).order(level: :desc).includes(:race, :character_class, :world, :guild)
  end

  def find_character
    @character = Character.where(user: Current.user).find_by(id: params[:id])
    render_not_found('Object is not found') if @character.nil?
  end

  def find_selectors
    @race_names = Race.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
    @character_class_names = CharacterClass.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
    @guild_names = Guild.order(name: :asc).map { |elem| [elem.full_name(I18n.locale.to_s), elem.id] }
    @dungeons_with_key = Dungeon.with_key
    @dungeons_with_quest = Dungeon.with_quest
  end

  def character_params
    h = params.require(:character).permit(:name, :level).to_h
    h[:race] = Race.find_by(id: params[:character][:race_id])
    h[:character_class] = CharacterClass.find_by(id: params[:character][:character_class_id])
    h[:world] = World.find_by(id: params[:character][:world_id]) if params[:character][:world_id].present?
    h[:guild] = Guild.find_by(id: params[:character][:guild_id])
    h[:user] = Current.user
    h
  end

  def dungeon_params
    params.require(:character).permit(dungeon: {})[:dungeon]
  end
end
