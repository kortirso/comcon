module Api
  module V1
    class CharactersController < Api::V1::BaseController
      before_action :find_character, only: %i[show update]

      resource_description do
        short 'Character resources'
        formats ['json']
      end

      api :GET, '/v1/characters/:id.json', 'Show character info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: {
          character: CharacterEditSerializer.new(@character)
        }, status: 200
      end

      api :POST, '/v1/characters.json', 'Create character'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        character_form = CharacterForm.new(character_params)
        if character_form.persist?
          CreateCharacterRoles.call(character_id: character_form.character.id, character_role_params: character_role_params)
          CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
          render json: character_form.character, status: 201
        else
          render json: { errors: character_form.errors.full_messages }, status: 409
        end
      end

      api :PATCH, '/v1/characters/:id.json', 'Update character'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        character_form = CharacterForm.new(@character.attributes.merge(character_params))
        if character_form.persist?
          character_form.character.character_roles.destroy_all
          CreateCharacterRoles.call(character_id: character_form.character.id, character_role_params: character_role_params)
          CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
          render json: character_form.character, status: 200
        else
          render json: { errors: character_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/characters/default_values.json', 'Show default_values for new characters'
      error code: 401, desc: 'Unauthorized'
      def default_values
        render json: {
          races: ActiveModelSerializers::SerializableResource.new(Race.order(id: :asc), each_serializer: RaceSerializer).as_json[:races],
          character_classes: ActiveModelSerializers::SerializableResource.new(CharacterClass.order(id: :asc), each_serializer: CharacterClassSerializer).as_json[:character_classes],
          guilds: ActiveModelSerializers::SerializableResource.new(Guild.order(id: :asc).includes(:fraction, :world), each_serializer: GuildSerializer).as_json[:guilds],
          worlds: ActiveModelSerializers::SerializableResource.new(World.order(id: :asc), each_serializer: WorldSerializer).as_json[:worlds],
          roles: ActiveModelSerializers::SerializableResource.new(Role.order(id: :asc), each_serializer: RoleSerializer).as_json[:roles],
          dungeons: ActiveModelSerializers::SerializableResource.new(Dungeon.order(id: :asc), each_serializer: DungeonSerializer).as_json[:dungeons]
        }, status: 200
      end

      private

      def find_character
        @character = Current.user.characters.find_by(id: params[:id])
        render_error('Object is not found') if @character.nil?
      end

      def character_params
        h = params.require(:character).permit(:name, :level).to_h
        h[:race] = Race.find_by(id: params[:character][:race_id])
        h[:character_class] = CharacterClass.find_by(id: params[:character][:character_class_id])
        h[:world] = World.find_by(id: params[:character][:world_id]) if params[:character][:world_id].present?
        h[:guild] = Guild.find_by(id: params[:character][:guild_id])
        h[:user] = Current.user
        h
      end

      def dungeon_params
        params.require(:character).permit(dungeon: {})[:dungeon]
      end

      def character_role_params
        params.require(:character).permit(:main_role_id, roles: {}).to_h
      end
    end
  end
end
