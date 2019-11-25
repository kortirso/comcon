module Api
  module V1
    class CharactersController < Api::V1::BaseController
      include Concerns::RaceCacher
      include Concerns::WorldCacher
      include Concerns::DungeonCacher
      include Concerns::ProfessionCacher

      before_action :find_character, only: %i[show update upload_recipes]
      before_action :get_races_from_cache, only: %i[default_values]
      before_action :get_worlds_from_cache, only: %i[default_values]
      before_action :get_dungeons_from_cache, only: %i[default_values]
      before_action :get_professions_from_cache, only: %i[default_values]
      before_action :search_characters, only: %i[search]
      before_action :find_profession, only: %i[upload_recipes]

      resource_description do
        short 'Character resources'
        formats ['json']
      end

      api :GET, '/v1/characters/:id.json', 'Show character info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: {
          character: CharacterShowSerializer.new(@character)
        }, status: 200
      end

      api :POST, '/v1/characters.json', 'Create character'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        character_form = CharacterForm.new(character_params)
        if character_form.persist?
          create_additional_structures_for_character(character_form.character)
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
        authorize! @character
        character_form = CharacterForm.new(@character.attributes.merge(character_params))
        if character_form.persist?
          character_form.character.character_roles.destroy_all
          create_additional_structures_for_character(character_form.character)
          render json: character_form.character, status: 200
        else
          render json: { errors: character_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/characters/default_values.json', 'Show default_values for new characters'
      error code: 401, desc: 'Unauthorized'
      def default_values
        render json: {
          races: @races_json,
          worlds: @worlds_json,
          dungeons: @dungeons_json,
          professions: @professions_json
        }, status: 200
      end

      api :GET, '/v1/characters/search.json', 'Search characters by name with params'
      error code: 401, desc: 'Unauthorized'
      def search
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters, root: 'characters', each_serializer: CharacterCrafterSerializer).as_json[:characters]
        }, status: 200
      end

      api :POST, '/v1/characters/:id/upload_recipes.json', 'Upload recipes for character'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 400, desc: 'Object is not found'
      def upload_recipes
        result = CharacterRecipesUpload.call(character_id: @character.id, profession_id: @profession.id, value: params[:value])
        return render json: { result: 'Recipes are uploaded' }, status: 200 unless result.nil?
        render json: { result: 'Recipes are not uploaded' }, status: 409
      end

      private

      def find_character
        @character = Current.user.characters.find_by(id: params[:id])
        render_error('Object is not found') if @character.nil?
      end

      def search_characters
        @characters = Character.search "*#{params[:query]}*", with: define_additional_search_params
      end

      def define_additional_search_params(with = {})
        with[:world_id] = params[:world_id].to_i if params[:world_id].present?
        with[:character_class_id] = params[:character_class_id].to_i if params[:character_class_id].present?
        if params[:race_id].present?
          with[:race_id] = params[:race_id].to_i
        elsif params[:fraction_id].present?
          fraction = Fraction.find_by(id: params[:fraction_id])
          with[:race_id] = fraction.races.pluck(:id) unless fraction.nil?
        end
        with
      end

      def find_profession
        @profession = Profession.recipeable.find_by(id: params[:profession_id])
        render_error('Object is not found') if @profession.nil?
      end

      def create_additional_structures_for_character(character)
        CreateCharacterRoles.call(character_id: character.id, character_role_params: character_role_params)
        CreateDungeonAccess.call(character_id: character.id, dungeon_params: dungeon_params)
        CreateCharacterProfessions.call(character_id: character.id, profession_params: profession_params)
      end

      def character_params
        h = params.require(:character).permit(:name, :level).to_h
        h[:race] = @character.nil? ? Race.find_by(id: params[:character][:race_id]) : @character.race
        h[:character_class] = @character.nil? ? CharacterClass.find_by(id: params[:character][:character_class_id]) : @character.character_class
        h[:world] = @character.nil? ? World.find_by(id: params[:character][:world_id]) : @character.world
        h[:world_fraction] = @character.world_fraction unless @character.nil?
        h[:guild] = @character.nil? ? nil : @character&.guild
        h[:user] = Current.user
        h
      end

      def dungeon_params
        params.require(:character).permit(dungeon: {})[:dungeon]
      end

      def character_role_params
        params.require(:character).permit(:main_role_id, roles: {}).to_h
      end

      def profession_params
        params.require(:character).permit(professions: {})[:professions]
      end
    end
  end
end
