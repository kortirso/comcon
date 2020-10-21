# frozen_string_literal: true

module Api
  module V1
    class GuildInvitesController < Api::V1::BaseController
      before_action :find_invite_creator, only: %i[index]
      before_action :find_guild, only: %i[create]
      before_action :find_character, only: %i[create]
      before_action :find_guild_invite, only: %i[destroy approve decline]

      def index
        authorize! @from_guild, with: GuildInvitePolicy, context: { guild: @invite_creator, character: @invite_creator }
        render json: (@invite_creator.is_a?(Guild) ? @invite_creator.guild_invites.includes(:character) : @invite_creator.guild_invites.includes(:guild)), status: :ok
      end

      def create
        authorize! params[:guild_invite][:from_guild], with: GuildInvitePolicy, context: { guild: @guild, character: @character }
        result = CreateGuildInvite.call(guild: @guild, character: @character, from_guild: params[:guild_invite][:from_guild])
        if result.success?
          render json: result.guild_invite, status: :created
        else
          render json: { errors: result.message }, status: :conflict
        end
      end

      def destroy
        authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
        @guild_invite.destroy
        render json: { result: 'Guild invite is deleted' }, status: :ok
      end

      def approve
        authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
        @guild_invite.character.update(guild_id: @guild_invite.guild.id)
        @guild_invite.character.guild_invites.destroy_all
        render json: { result: 'Character is added to the guild' }, status: :ok
      end

      def decline
        authorize! @guild_invite.from_guild.to_s, with: GuildInvitePolicy, context: { guild: @guild_invite.guild, character: @guild_invite.character }
        UpdateGuildInvite.call(guild_invite: @guild_invite, status: 1)
        render json: { result: 'Guild invite is declined' }, status: :ok
      end

      private

      def find_invite_creator
        if params[:guild_id].present?
          @invite_creator = Guild.find_by(id: params[:guild_id])
          render_error(t('custom_errors.object_not_found'), 404) if @invite_creator.nil?
          @from_guild = 'true'
        elsif params[:character_id].present?
          @invite_creator = Character.where(user_id: Current.user.id, guild_id: nil).find_by(id: params[:character_id])
          render_error(t('custom_errors.object_not_found'), 404) if @invite_creator.nil?
          @from_guild = 'false'
        else
          render_error('Guild ID or Character ID must be presented', 400)
        end
      end

      def find_guild
        @guild = Guild.find_by(id: params[:guild_invite][:guild_id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

      def find_character
        @character = Character.find_by(id: params[:guild_invite][:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def find_guild_invite
        @guild_invite = GuildInvite.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild_invite.nil?
      end
    end
  end
end
