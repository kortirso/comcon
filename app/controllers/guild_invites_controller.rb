class GuildInvitesController < ApplicationController
  before_action :find_guild, only: %i[new]
  before_action :find_guild_invite, only: %i[destroy approve decline]

  def new
    authorize! @from_guild, with: GuildInvitePolicy, context: { guild: @invite_creator, character: @invite_creator }
  end

  def destroy
    authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
    @guild_invite.destroy
    redirect_to management_guild_path(@guild_invite.guild.slug)
  end

  def approve
    authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
    @guild_invite.character.update(guild_id: @guild_invite.guild.id)
    @guild_invite.destroy
    redirect_to guild_path(@guild_invite.guild.slug)
  end

  def decline
    authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
    UpdateGuildInvite.call(guild_invite: @guild_invite, status: 1)
    redirect_to guilds_path
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

  def find_guild_invite
    @guild_invite = GuildInvite.find_by(id: params[:id])
    render_error('Object is not found') if @guild_invite.nil?
  end
end
