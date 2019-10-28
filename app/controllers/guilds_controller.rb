class GuildsController < ApplicationController
  before_action :find_guild, only: %i[show]
  before_action :find_user_characters, only: %i[show]

  def index; end

  def show; end

  private

  def find_guild
    @guild = Guild.find_by(slug: params[:id])
    render_error('Object is not found') if @guild.nil?
  end

  def find_user_characters
    @user_characters = Current.user.characters.where(guild_id: @guild.id)
  end
end
