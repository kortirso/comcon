module Api
  module V2
    module Concerns
      module RecipeCacher
        extend ActiveSupport::Concern

        private

        def get_recipes_from_cache
          recipes = Recipe.order(profession_id: :desc, skill: :desc)
          @recipes_json = Rails.cache.fetch(Recipe.cache_key(recipes, :v2)) do
            FastRecipeSerializer.new(recipes).serializable_hash
          end
        end
      end
    end
  end
end
