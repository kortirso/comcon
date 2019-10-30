module Api
  module V1
    module Concerns
      module RecipeCacher
        extend ActiveSupport::Concern

        private

        def get_recipes_from_cache
          recipes = Recipe.order(profession_id: :desc, skill: :desc)
          @recipes_json = Rails.cache.fetch(Recipe.cache_key(recipes)) do
            ActiveModelSerializers::SerializableResource.new(recipes, each_serializer: RecipeSerializer).as_json[:recipes]
          end
        end
      end
    end
  end
end
