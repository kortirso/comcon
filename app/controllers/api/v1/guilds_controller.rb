module Api
  module V1
    class GuildsController < Api::V1::BaseController
      before_action :find_guilds, only: %i[index]
      before_action :find_guild, only: %i[characters kick_character]
      before_action :find_guild_character, only: %i[kick_character]
      before_action :find_guild_characters, only: %i[characters]

      resource_description do
        short 'Guild resources'
        formats ['json']
      end

      api :GET, '/v1/guilds.json', 'Get list of guilds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildSerializer).as_json[:guilds]
        }, status: 200
      end

      api :GET, '/v1/guilds/:id/characters.json', 'Get list of guilds'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def characters
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@guild_characters, each_serializer: GuildCharacterSerializer).as_json[:characters]
        }, status: 200
      end

      api :GET, '/v1/guilds/:id/kick_character.json', 'Kick character from guild'
      param :id, String, required: true
      param :character_id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def kick_character
        authorize! @guild, to: :management?
        @character.update(guild_id: nil)
        render json: { result: 'Character is kicked from guild' }, status: 200
      end

      private

      def find_guilds
        @guilds = Guild.order(name: :asc).includes(:fraction, :world)
        @guilds = @guilds.where(world_id: params[:world_id]) if params[:world_id].present?
        @guilds = @guilds.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
      end

      def find_guild
        @guild = Guild.find_by(slug: params[:id])
        render_error('Object is not found') if @guild.nil?
      end

      def find_guild_character
        @character = @guild.characters.find_by(id: params[:character_id])
        render_error('Object is not found') if @character.nil?
      end

      def find_guild_characters
        @guild_characters = @guild.characters.includes(:race, :character_class, :guild_role).order(level: :desc, character_class_id: :desc)
      end
    end
  end
end
