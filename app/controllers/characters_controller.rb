class CharactersController < ApplicationController
  before_action :find_characters, only: %i[index]
  before_action :find_character, only: %i[edit destroy]

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
end
