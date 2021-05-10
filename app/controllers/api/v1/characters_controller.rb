# frozen_string_literal: true

module Api
  module V1
    class CharactersController < Api::V1::BaseController
      include Concerns::RaceCacher
      include Concerns::CharacterClassCacher
      include Concerns::WorldCacher
      include Concerns::DungeonCacher
      include Concerns::ProfessionCacher

      before_action :find_characters, only: %i[index]
      before_action :find_character, only: %i[show update upload_recipes]
      before_action :get_races_from_cache, only: %i[default_values]
      before_action :get_character_classes_from_cache, only: %i[default_values]
      before_action :get_worlds_from_cache, only: %i[default_values]
      before_action :get_dungeons_from_cache, only: %i[default_values]
      before_action :get_professions_from_cache, only: %i[default_values]
      before_action :find_event_for_search, only: %i[search_for_event]
      before_action :search_characters, only: %i[search search_for_event]
      before_action :select_unsubscribed_characters, only: %i[search_for_event]
      before_action :find_profession, only: %i[upload_recipes]

      def index
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters, each_serializer: CharacterIndexSerializer).as_json[:characters]
        }, status: :ok
      end

      def show
        render json: {
          character: CharacterShowSerializer.new(@character)
        }, status: :ok
      end

      def create
        character_form = CharacterForm.new(character_params)
        if character_form.persist?
          create_additional_structures_for_character(character_form.character)
          render json: character_form.character, status: :created
        else
          render json: { errors: character_form.errors.full_messages }, status: :conflict
        end
      end

      def update
        authorize! @character
        character_form = CharacterForm.new(@character.attributes.merge(character_params))
        if character_form.persist?
          character_form.character.character_roles.destroy_all
          create_additional_structures_for_character(character_form.character)
          render json: character_form.character, status: :ok
        else
          render json: { errors: character_form.errors.full_messages }, status: :conflict
        end
      end

      def default_values
        render json: {
          races:             @races_json,
          character_classes: @character_classes,
          worlds:            @worlds_json,
          dungeons:          @dungeons_json,
          professions:       @professions_json
        }, status: :ok
      end

      def search
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters, root: 'characters', each_serializer: CharacterCrafterSerializer).as_json[:characters]
        }, status: :ok
      end

      def search_for_event
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters, root: 'characters', each_serializer: CharacterCrafterSerializer).as_json[:characters]
        }, status: :ok
      end

      def upload_recipes
        result = CharacterRecipesUpload.call(character_id: @character.id, profession_id: @profession.id, value: params[:value])
        return render json: { result: 'Recipes are uploaded' }, status: :ok unless result.nil?

        render json: { result: 'Recipes are not uploaded' }, status: :conflict
      end

      private

      def find_characters
        @characters = Current.user.characters.includes(race: :fraction)
      end

      def find_character
        @character = Current.user.characters.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def search_characters
        @characters = Character.search "*#{params[:query]}*", with: define_additional_search_params
      end

      def define_additional_search_params(with={})
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

      def find_event_for_search
        @event = Event.find_by(id: params[:event_id])
        render_error(t('custom_errors.object_not_found'), 404) if @event.nil?
      end

      def select_unsubscribed_characters
        subscribed_character_ids = @event.characters.pluck(:id)
        @characters = @characters.reject { |character| subscribed_character_ids.include?(character.id) }
      end

      def find_profession
        @profession = Profession.recipeable.find_by(id: params[:profession_id])
        render_error(t('custom_errors.object_not_found'), 404) if @profession.nil?
      end

      def create_additional_structures_for_character(character)
        CreateCharacterRoles.call(character_id: character.id, character_role_params: character_role_params)
        CreateCharacterProfessions.call(character_id: character.id, profession_params: profession_params)
        CreateGuildInvite.call(character: character, guild: Guild.find_by(world_fraction: character.world_fraction, id: params[:character][:guild_id]), from_guild: false) if params[:character][:guild_id].present?
        character.user.characters.where.not(id: character.id).update_all(main: false) if character.main?
      end

      def character_params
        h = params.require(:character).permit(:name, :level, :main).to_h
        h[:race] = @character.nil? ? Race.find_by(id: params[:character][:race_id]) : @character.race
        h[:character_class] = @character.nil? ? CharacterClass.find_by(id: params[:character][:character_class_id]) : @character.character_class
        h[:world] = @character.nil? ? World.find_by(id: params[:character][:world_id]) : @character.world
        h[:world_fraction] = @character.world_fraction unless @character.nil?
        h[:guild] = @character.nil? ? nil : @character&.guild
        h[:user] = Current.user
        h
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
