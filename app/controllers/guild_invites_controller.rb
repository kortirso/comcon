class GuildInvitesController < ApplicationController
  before_action :find_guild, only: %i[new]

  def new
    authorize! @from_guild, with: GuildInvitePolicy, context: { guild: @invite_creator, character: @invite_creator }
  end

  private

  def find_guild
    if params[:guild_id].present?
      @invite_creator = Guild.find_by(id: params[:guild_id])
      render_error('Object is not found') if @invite_creator.nil?
      @from_guild = 'true'
    elsif params[:character_id].present?
      @invite_creator = Character.where(user_id: Current.user.id, guild_id: nil).find_by(id: params[:character_id])
      render_error('Object is not found') if @invite_creator.nil?
      @from_guild = 'false'
    else
      render_error('Guild ID or Character ID must be presented')
    end
  end
end
