class GuildsController < ApplicationController
  before_action :find_guild, only: %i[show]
  before_action :find_guild_characters, only: %i[show]

  def index; end

  def show; end

  private

  def find_guild
    @guild = Guild.find_by(slug: params[:id])
    render_error('Object is not found') if @guild.nil?
  end

  def find_guild_characters
    @guild_characters = @guild.characters.includes(:race, :character_class).order(level: :desc, character_class_id: :desc)
  end
end
