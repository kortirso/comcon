class CharactersController < ApplicationController
  before_action :find_characters, only: %i[index]
  before_action :find_character, only: %i[edit destroy]
  before_action :find_selectors, only: %i[new edit]

  def index; end

  def new; end

  def edit; end

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
    render_error('Object is not found') if @character.nil?
  end

  def find_selectors
    @race_names = Race.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
    @character_class_names = CharacterClass.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
    @guild_names = Guild.order(name: :asc).map { |elem| [elem.full_name(I18n.locale.to_s), elem.id] }
    @main_role_names = Role.order(id: :asc).map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
    @roles = Role.order(id: :asc)
    @dungeons_with_key = Dungeon.with_key
    @dungeons_with_quest = Dungeon.with_quest
  end
end
