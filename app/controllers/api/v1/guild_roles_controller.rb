module Api
  module V1
    class GuildRolesController < Api::V1::BaseController
      before_action :find_guild_role, only: %i[update destroy]
      before_action :find_guild, only: %i[create update]
      before_action :find_character, only: %i[create update]

      resource_description do
        short 'GuildRole resources'
        formats ['json']
      end

      api :POST, '/v1/guild_roles.json', 'Create guild role'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        # authorize! @guild, with: GuildRolePolicy
        guild_role_form = GuildRoleForm.new(guild_role_params)
        if guild_role_form.persist?
          render json: guild_role_form.guild_role, status: 201
        else
          render json: { errors: guild_role_form.errors.full_messages }, status: 409
        end
      end

      api :PATCH, '/v1/guild_roles/:id.json', 'Update guild role'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        # authorize! @guild_role, with: GuildRolePolicy
        guild_role_form = GuildRoleForm.new(@guild_role.attributes.merge(guild_role_params))
        if guild_role_form.persist?
          render json: guild_role_form.guild_role, status: 200
        else
          render json: { errors: guild_role_form.errors.full_messages }, status: 409
        end
      end

      api :DELETE, '/v1/guild_roles/:id.json', 'Delete guild role'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def destroy
        # authorize! @guild_role, with: GuildRolePolicy
        @guild_role.destroy
        render json: { result: 'Success' }, status: 200
      end

      private

      def find_guild_role
        @guild_role = GuildRole.find_by(id: params[:id])
        render_error('Object is not found') if @guild_role.nil?
      end

      def find_guild
        @guild = params[:guild_role][:guild_id].present? ? Guild.find_by(id: params[:guild_role][:guild_id]) : @guild_role&.guild
        render_error('Object is not found') if @guild.nil?
      end

      def find_character
        @character = params[:guild_role][:character_id].present? ? Character.find_by(id: params[:guild_role][:character_id]) : @guild_role&.character
        render_error('Object is not found') if @character.nil?
      end

      def guild_role_params
        h = params.require(:guild_role).permit(:name).to_h
        h[:guild] = @guild
        h[:character] = @character
        h
      end
    end
  end
end
