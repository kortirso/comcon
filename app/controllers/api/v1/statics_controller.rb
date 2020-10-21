# frozen_string_literal: true

module Api
  module V1
    class StaticsController < Api::V1::BaseController
      before_action :find_statics, only: %i[index]
      before_action :find_guild, only: %i[create]
      before_action :find_static, only: %i[show update members subscribers leave_character kick_character characters_for_request]
      before_action :find_user_guilds, only: %i[form_values]
      before_action :find_character, only: %i[leave_character]
      before_action :find_static_character, only: %i[kick_character]
      before_action :search_statics, only: %i[search]
      before_action :find_characters_for_request, only: %i[characters_for_request]

      def index
        render json: {
          statics: ActiveModelSerializers::SerializableResource.new(@statics, root: 'statics', each_serializer: StaticSerializer).as_json[:statics]
        }, status: :ok
      end

      def show
        authorize! @static
        render json: @static, status: :ok
      end

      def create
        authorize! @guild, to: :new?, with: StaticPolicy if @guild.present?
        static_form = StaticForm.new(static_params)
        if static_form.persist?
          static = static_form.static
          CreateGroupRole.call(groupable: static, group_roles: group_role_params)
          CreateStaticMember.call(static: static, character: static.staticable) unless static.for_guild?
          render json: static, status: :created
        else
          render json: { errors: static_form.errors.full_messages }, status: :conflict
        end
      end

      def update
        authorize! @static, to: :edit?
        static_form = StaticForm.new(@static.attributes.merge(update_static_params))
        if static_form.persist?
          UpdateGroupRole.call(group_role: @static.group_role, group_roles: group_role_params)
          render json: static_form.static, status: :ok
        else
          render json: { errors: static_form.errors.full_messages }, status: :conflict
        end
      end

      def form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters.includes(race: :fraction), each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildIndexSerializer).as_json[:guilds],
          group_roles: GroupRole.default
        }, status: :ok
      end

      def members
        authorize! @static, to: :edit?
        render json: {
          members: ActiveModelSerializers::SerializableResource.new(@static.static_members.includes(character: %i[character_class guild world race]), each_serializer: StaticMemberSerializer).as_json[:static_members],
          invites: ActiveModelSerializers::SerializableResource.new(@static.static_invites, each_serializer: StaticInviteSerializer).as_json[:static_invites]
        }, status: :ok
      end

      def subscribers
        authorize! @static, to: :show?
        render json: {
          subscribes: ActiveModelSerializers::SerializableResource.new(@static.subscribes.status_order.includes(character: %i[character_class guild]), each_serializer: SubscribeSerializer).as_json[:subscribes]
        }, status: :ok
      end

      def kick_character
        authorize! @static, to: :edit?
        LeaveFromStatic.call(character: @character, static: @static)
        UpdateStaticLeftValue.call(group_role: @static.group_role)
        render json: { result: 'Character is kicked from static' }, status: :ok
      end

      def leave_character
        LeaveFromStatic.call(character: @character, static: @static)
        UpdateStaticLeftValue.call(group_role: @static.group_role)
        render json: { result: 'Character is left from static' }, status: :ok
      end

      def search
        render json: {
          statics: ActiveModelSerializers::SerializableResource.new(@statics, root: 'statics', each_serializer: StaticIndexSerializer).as_json[:statics]
        }, status: :ok
      end

      def characters_for_request
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters_for_request, each_serializer: CharacterIndexSerializer).as_json[:characters]
        }, status: :ok
      end

      private

      def find_statics
        @statics = Static.not_privy.order(name: :asc).includes(:fraction, :group_role, staticable: :world)
        @statics = @statics.where(world_id: params[:world_id]) if params[:world_id].present?
        @statics = @statics.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
        return unless params[:character_id].present?

        character = Current.user.characters.find_by(id: params[:character_id])
        return unless character.present?

        @statics = @statics.includes(:group_role).select { |static| static.group_role.left_value[main_role(character)]['by_class'][class_name(character)].positive? }
      end

      def main_role(character)
        case character.main_roles[0].name['en']
        when 'Tank' then 'tanks'
        when 'Healer' then 'healers'
        else 'dd'
        end
      end

      def class_name(character)
        character.character_class.name['en'].downcase
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

      def find_static_character
        @character = @static.characters.find_by(id: params[:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def find_character
        @character = Current.user.characters.find_by(id: params[:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def search_statics
        @statics = Static.search "*#{params[:query]}*", with: define_additional_search_params
      end

      def define_additional_search_params(with={})
        with[:world_id] = params[:world_id].to_i if params[:world_id].present?
        with[:fraction_id] = params[:fraction_id].to_i if params[:fraction_id].present?
        with
      end

      def find_characters_for_request
        existed_static_invite_ids = StaticInvite.where(static_id: @static.id).pluck(:character_id)
        existed_static_member_ids = StaticMember.where(static_id: @static.id).pluck(:character_id)
        @characters_for_request = Current.user.characters.where(world_fraction_id: @static.world_fraction_id).where.not(id: existed_static_invite_ids).where.not(id: existed_static_member_ids).includes(race: :fraction).order(id: :asc)
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
