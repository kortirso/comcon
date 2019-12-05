module Api
  module V1
    class GuildsController < Api::V1::BaseController
      before_action :find_guilds, only: %i[index]
      before_action :find_guild_by_slug, only: %i[characters kick_character leave_character]
      before_action :find_guild, only: %i[show update characters_for_request]
      before_action :find_guild_character, only: %i[kick_character]
      before_action :find_user_character_in_guild, only: %i[leave_character]
      before_action :find_guild_characters, only: %i[characters]
      before_action :search_guilds, only: %i[search]
      before_action :find_user_characters_for_guild, only: %i[form_values]
      before_action :find_characters_for_request, only: %i[characters_for_request]

      resource_description do
        short 'Guild resources'
        formats ['json']
      end

      api :GET, '/v1/guilds.json', 'Get list of guilds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildIndexSerializer).as_json[:guilds]
        }, status: 200
      end

      api :GET, '/v1/guilds/:id.json', 'Show guild info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: { guild: GuildShowSerializer.new(@guild) }, status: 200
      end

      api :POST, '/v1/guilds.json', 'Create guild'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        result = CreateNewGuild.call(guild_params: guild_params, owner_id: params[:guild][:owner_id], user: Current.user, name: 'gm')
        if result.success?
          render json: { guild: GuildShowSerializer.new(result.guild) }, status: 201
        else
          render json: { errors: result.message }, status: 409
        end
      end

      api :PATCH, '/v1/guilds/:id.json', 'Update guild'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        guild_form = GuildForm.new(@guild.attributes.merge(guild_params.merge(world: @guild.world, fraction: @guild.fraction, world_fraction: @guild.world_fraction)))
        if guild_form.persist?
          render json: { guild: GuildShowSerializer.new(guild_form.guild) }, status: 200
        else
          render json: { errors: guild_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/guilds/:id/characters.json', 'Get list of guilds'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def characters
        render json: {
          characters: @guild_characters
        }, status: 200
      end

      api :GET, '/v1/guilds/form_values.json', 'Get form_values for guild form'
      error code: 401, desc: 'Unauthorized'
      def form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@user_characters, each_serializer: CharacterIndexSerializer).as_json[:characters]
        }, status: 200
      end

      api :POST, '/v1/guilds/:id/kick_character.json', 'Kick character from guild'
      param :id, String, required: true
      param :character_id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def kick_character
        authorize! @guild, to: :management?
        @character.update(guild_id: nil)
        RebuildGuildRoles.call(guild: @guild)
        render json: { result: 'Character is kicked from guild' }, status: 200
      end

      api :POST, '/v1/guilds/:id/leave_character.json', 'Character leave from guild'
      param :id, String, required: true
      param :character_id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def leave_character
        @character.update(guild_id: nil)
        RebuildGuildRoles.call(guild: @guild)
        render json: { result: 'Character is left from guild' }, status: 200
      end

      api :GET, '/v1/guilds/search.json', 'Search guilds by name with params'
      error code: 401, desc: 'Unauthorized'
      def search
        render json: {
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, root: 'guilds', each_serializer: GuildIndexSerializer).as_json[:guilds]
        }, status: 200
      end

      api :GET, '/v1/guilds/:id/characters_for_request.json', 'Get list of characters for request to guild'
      error code: 401, desc: 'Unauthorized'
      def characters_for_request
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters_for_request, each_serializer: CharacterIndexSerializer).as_json[:characters]
        }, status: 200
      end

      private

      def find_guilds
        @guilds = Guild.includes(:fraction, :world).order('worlds.name asc').order(name: :asc, id: :asc).references(:world)
        @guilds = @guilds.where(world_id: params[:world_id]) if params[:world_id].present?
        @guilds = @guilds.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
      end

      def find_guild_by_slug
        @guild = Guild.find_by(slug: params[:id])
        render_error('Object is not found') if @guild.nil?
      end

      def find_guild
        @guild = Guild.find_by(id: params[:id])
        render_error('Object is not found') if @guild.nil?
      end

      def find_guild_character
        @character = @guild.characters.where.not(user_id: Current.user.id).find_by(id: params[:character_id])
        render_error('Object is not found') if @character.nil?
      end

      def find_user_character_in_guild
        @character = @guild.characters.where(user_id: Current.user.id).find_by(id: params[:character_id])
        render_error('Object is not found') if @character.nil?
      end

      def find_guild_characters
        @guild_characters = ActiveModelSerializers::SerializableResource.new(@guild.characters.includes(:race, :character_class, :main_roles, :guild_role), each_serializer: GuildCharacterSerializer).as_json[:characters].sort_by { |character| [- character[:level], character[:character_class_name]['en'], Role::ROLE_VALUES[character[:main_role_name]['en']], character[:name]] }
      end

      def find_characters_for_request
        existed_guild_invite_ids = GuildInvite.where(guild_id: @guild.id).pluck(:character_id)
        @characters_for_request = Current.user.characters.where(guild_id: nil, world_fraction_id: @guild.world_fraction_id).where.not(id: existed_guild_invite_ids)
      end

      def search_guilds
        @guilds = Guild.search "*#{params[:query]}*", with: define_additional_search_params
      end

      def define_additional_search_params(with = {})
        with[:world_id] = params[:world_id].to_i if params[:world_id].present?
        with[:fraction_id] = params[:fraction_id].to_i if params[:fraction_id].present?
        with
      end

      def find_user_characters_for_guild
        @user_characters = Current.user.characters.where(guild_id: nil)
      end

      def guild_params
        params.require(:guild).permit(:name, :description)
      end
    end
  end
end
