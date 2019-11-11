module Api
  module V1
    class CraftController < Api::V1::BaseController
      include Concerns::WorldCacher
      include Concerns::FractionCacher
      include Concerns::GuildCacher
      include Concerns::ProfessionCacher

      before_action :get_worlds_from_cache, only: %i[filter_values]
      before_action :get_fractions_from_cache, only: %i[filter_values]
      before_action :get_guilds_from_cache, only: %i[filter_values]
      before_action :get_professions_from_cache, only: %i[filter_values]
      before_action :find_recipe, only: %i[search]
      before_action :find_characters, only: %i[search]

      def filter_values
        render json: {
          worlds: @worlds_json,
          fractions: @fractions_json,
          guilds: @guilds_json,
          professions: @professions_json
        }, status: 200
      end

      def search
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(@characters.includes(:race, :character_class, guild: %i[fraction world]), each_serializer: CharacterCrafterSerializer).as_json[:characters]
        }, status: 200
      end

      private

      def find_recipe
        @recipe = Recipe.find_by(id: params[:recipe_id])
        render_error('Object is not found') if @recipe.nil?
      end

      def find_characters
        character_ids = @recipe.character_profession.pluck(:character_id)
        @characters = Character.where(id: character_ids)
        if params[:guild_id].present?
          @characters = @characters.where(guild_id: params[:guild_id])
        else
          @characters = @characters.where(world_id: params[:world_id]) if params[:world_id].present?
          @characters = @characters.includes(:race).where('races.fraction_id = ?', params[:fraction_id]).references(:race) if params[:fraction_id].present?
        end
      end
    end
  end
end
