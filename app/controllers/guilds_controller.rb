class GuildsController < ApplicationController
  before_action :find_guild_invites_for_user, only: %i[index]
  before_action :find_guild_by_slug, only: %i[show edit management statics notifications bank]
  before_action :find_user_characters, only: %i[show]

  def index; end

  def show; end

  def new; end

  def edit
    authorize! @guild
  end

  def management
    authorize! @guild
  end

  def statics
    authorize! @guild, to: :management?
  end

  def notifications
    authorize! @guild, to: :management?
  end

  def bank
    authorize! @guild
  end

  private

  def find_guild_invites_for_user
    @guild_invites = Current.user.guild_invites
  end

  def find_guild_by_slug
    @guild = Guild.find_by(slug: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
  end

  def find_user_characters
    @user_characters = Current.user.characters.where(guild_id: @guild.id)
  end
end
