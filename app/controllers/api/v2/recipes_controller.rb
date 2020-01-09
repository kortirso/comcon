module Api
  module V2
    class RecipesController < Api::V1::BaseController
      include Concerns::RecipeCacher

      before_action :is_admin?, except: %i[search]
      before_action :get_recipes_from_cache, only: %i[index]

      resource_description do
        short 'Recipe resources'
        formats ['json']
      end

      api :GET, '/v2/recipes.json', 'Get all recipes'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { recipes: @recipes_json }, status: 200
      end
    end
  end
end
