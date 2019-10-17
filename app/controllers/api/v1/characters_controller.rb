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
        render json: @character, status: 200
      end

      api :POST, '/v1/characters.json', 'Create character'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        character_form = CharacterForm.new(character_params)
        if character_form.persist?
          # CreateCharacterRoles.call(character_id: character_form.character.id, character_role_params: character_role_params)
          # CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
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
          # CreateCharacterRoles.call(character_id: character_form.character.id, character_role_params: character_role_params)
          # CreateDungeonAccess.call(character_id: character_form.character.id, dungeon_params: dungeon_params)
          render json: character_form.character, status: 200
        else
          render json: { errors: character_form.errors.full_messages }, status: 409
        end
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
