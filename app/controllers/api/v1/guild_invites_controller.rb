module Api
  module V1
    class GuildInvitesController < Api::V1::BaseController
      before_action :find_guild, only: %i[create]
      before_action :find_character, only: %i[create]

      resource_description do
        short 'GuildInvite resources'
        formats ['json']
      end

      api :POST, '/v1/guild_invites.json', 'Create guild invite'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! params[:guild_invite][:from_guild], with: GuildInvitePolicy, context: { guild: @guild, character: @character }
        result = CreateGuildInvite.call(guild: @guild, character: @character, from_guild: params[:guild_invite][:from_guild])
        if result.success?
          render json: result.guild_invite, status: 201
        else
          render json: { errors: result.message }, status: 409
        end
      end

      private

      def find_guild
        @guild = Guild.find_by(id: params[:guild_invite][:guild_id])
        render_error('Object is not found') if @guild.nil?
      end

      def find_character
        @character = Character.find_by(id: params[:guild_invite][:character_id])
        render_error('Object is not found') if @character.nil?
      end
    end
  end
end
