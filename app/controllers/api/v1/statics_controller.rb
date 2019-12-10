module Api
  module V1
    class StaticsController < Api::V1::BaseController
      before_action :find_statics, only: %i[index]
      before_action :find_guild, only: %i[create]
      before_action :find_static, only: %i[show update members subscribers leave_character]
      before_action :find_user_guilds, only: %i[form_values]
      before_action :find_character, only: %i[leave_character]
      before_action :search_statics, only: %i[search]

      resource_description do
        short 'Static resources'
        formats ['json']
      end

      api :GET, '/v1/statics.json', 'Get list of public statics'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          statics: ActiveModelSerializers::SerializableResource.new(@statics, each_serializer: StaticSerializer).as_json[:statics]
        }, status: 200
      end

      api :GET, '/v1/statics/:id.json', 'Show static info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        authorize! @static
        render json: @static, status: 200
      end

      api :POST, '/v1/statics.json', 'Create static'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @guild, to: :new?, with: StaticPolicy if @guild.present?
        static_form = StaticForm.new(static_params)
        if static_form.persist?
          static = static_form.static
          CreateGroupRole.call(groupable: static, group_roles: group_role_params)
          CreateStaticMember.call(static: static, character: static.staticable) unless static.for_guild?
          render json: static, status: 201
        else
          render json: { errors: static_form.errors.full_messages }, status: 409
        end
      end

      api :POST, '/v1/statics/:id.json', 'Update static'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        authorize! @static, to: :edit?
        static_form = StaticForm.new(@static.attributes.merge(update_static_params))
        if static_form.persist?
          UpdateGroupRole.call(group_role: @static.group_role, group_roles: group_role_params)
          render json: static_form.static, status: 200
        else
          render json: { errors: static_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/statics/form_values.json', 'Get form_values for static form'
      error code: 401, desc: 'Unauthorized'
      def form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters.includes(race: :fraction), each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildIndexSerializer).as_json[:guilds],
          group_roles: GroupRole.default
        }, status: 200
      end

      api :GET, '/v1/statics/:id/members.json', 'Show static members'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def members
        authorize! @static, to: :edit?
        render json: {
          members: ActiveModelSerializers::SerializableResource.new(@static.static_members.includes(character: %i[character_class guild world race]), each_serializer: StaticMemberSerializer).as_json[:static_members],
          invites: ActiveModelSerializers::SerializableResource.new(@static.static_invites, each_serializer: StaticInviteSerializer).as_json[:static_invites]
        }, status: 200
      end

      api :GET, '/v1/statics/:id/subscribers.json', 'Show static subscribers'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def subscribers
        authorize! @static, to: :show?
        render json: @static.subscribes.status_order.includes(character: %i[character_class guild]), status: 200
      end

      api :POST, '/v1/statics/:id/leave_character.json', 'Character leave from static'
      param :id, String, required: true
      param :character_id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Object is not found'
      def leave_character
        LeaveFromStatic.call(character: @character, static: @static)
        UpdateStaticLeftValue.call(group_role: @static.group_role)
        render json: { result: 'Character is left from static' }, status: 200
      end

      api :GET, '/v1/statics/search.json', 'Search statics by name with params'
      error code: 401, desc: 'Unauthorized'
      def search
        render json: {
          statics: ActiveModelSerializers::SerializableResource.new(@statics, root: 'statics', each_serializer: StaticIndexSerializer).as_json[:statics]
        }, status: 200
      end

      private

      def find_statics
        @statics = Static.not_privy.order(name: :asc).includes(:fraction, :group_role, staticable: :world)
        @statics = @statics.where(world_id: params[:world_id]) if params[:world_id].present?
        @statics = @statics.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
      end

      def find_guild
        return unless params[:static][:staticable_type] == 'Guild'
        @guild = Guild.find_by(id: params[:static][:staticable_id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

      def find_static
        @static = Static.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @static.nil?
      end

      def find_user_guilds
        guild_ids = Current.user.characters.includes(:guild_role).where('guild_roles.name = ? OR guild_roles.name = ?', 'gm', 'rl').references(:guild_role).pluck(:guild_id)
        @guilds = Guild.where(id: guild_ids).includes(:world, :fraction)
      end

      def find_character
        @character = Current.user.characters.find_by(id: params[:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def search_statics
        @statics = Static.search "*#{params[:query]}*", with: define_additional_search_params
      end

      def define_additional_search_params(with = {})
        with[:world_id] = params[:world_id].to_i if params[:world_id].present?
        with[:fraction_id] = params[:fraction_id].to_i if params[:fraction_id].present?
        with
      end

      def static_params
        params.require(:static).permit(:name, :description, :staticable_id, :staticable_type, :privy)
      end

      def update_static_params
        params.require(:static).permit(:name, :description, :privy)
      end

      def group_role_params
        params.require(:static).permit(group_roles: {})
      end
    end
  end
end
