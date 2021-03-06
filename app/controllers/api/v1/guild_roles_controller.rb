# frozen_string_literal: true

module Api
  module V1
    class GuildRolesController < Api::V1::BaseController
      before_action :find_guild_role, only: %i[update destroy]
      before_action :find_guild, only: %i[create update]
      before_action :find_character, only: %i[create update]

      def create
        authorize! @guild, with: GuildRolePolicy
        result = CreateGuildRole.call(guild: @guild, character: @character, name: params[:guild_role][:name])
        if result.success?
          CheckAddedHeadRole.call(guild_role: result.guild_role)
          render json: result.guild_role, status: :created
        else
          render json: { errors: result.message }, status: :conflict
        end
      end

      def update
        authorize! @guild_role
        guild_role_form = GuildRoleForm.new(@guild_role.attributes.merge(guild: @guild, character: @character, name: params[:guild_role][:name]))
        if guild_role_form.persist?
          CheckAddedHeadRole.call(guild_role: guild_role_form.guild_role)
          render json: guild_role_form.guild_role, status: :ok
        else
          render json: { errors: guild_role_form.errors.full_messages }, status: :conflict
        end
      end

      def destroy
        authorize! @guild_role
        CheckRemovedHeadRole.call(guild_role: @guild_role)
        @guild_role.destroy
        render json: { result: 'Success' }, status: :ok
      end

      private

      def find_guild_role
        @guild_role = GuildRole.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild_role.nil?
      end

      def find_guild
        @guild = params[:guild_role][:guild_id].present? ? Guild.find_by(id: params[:guild_role][:guild_id]) : @guild_role&.guild
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

      def find_character
        @character = params[:guild_role][:character_id].present? ? Character.find_by(id: params[:guild_role][:character_id]) : @guild_role&.character
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end
    end
  end
end
