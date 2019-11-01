module Api
  module V1
    class StaticsController < Api::V1::BaseController
      before_action :find_guild, only: %i[create]
      before_action :find_user_guilds, only: %i[form_values]

      api :POST, '/v1/statics.json', 'Create static'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @guild, with: StaticPolicy if @guild.present?
        static_form = StaticForm.new(static_params)
        if static_form.persist?
          render json: static_form.static, status: 201
        else
          render json: { errors: static_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/statics/form_values.json', 'Get form_values for static form'
      error code: 401, desc: 'Unauthorized'
      def form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildIndexSerializer).as_json[:guilds]
        }, status: 200
      end

      private

      def find_guild
        return unless params[:static][:staticable_type] == 'Guild'
        @guild = Guild.find_by(id: params[:static][:staticable_id])
        render_error('Object is not found') if @guild.nil?
      end

      def find_user_guilds
        guild_ids = Current.user.characters.includes(:guild_role).where('guild_roles.name = ? OR guild_roles.name = ?', 'gm', 'rl').references(:guild_role).pluck(:guild_id)
        @guilds = Guild.where(id: guild_ids).includes(:fraction, :world)
      end

      def static_params
        params.require(:static).permit(:name, :staticable_id, :staticable_type, :description)
      end
    end
  end
end
