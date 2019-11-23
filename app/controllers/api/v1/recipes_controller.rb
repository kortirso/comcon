module Api
  module V1
    class RecipesController < Api::V1::BaseController
      include Concerns::RecipeCacher

      before_action :is_admin?, except: %i[search]
      before_action :get_recipes_from_cache, only: %i[index]
      before_action :find_recipe, only: %i[show update]
      before_action :search_recipes, only: %i[search]

      resource_description do
        short 'Recipe resources'
        formats ['json']
      end

      api :GET, '/v1/recipes.json', 'Get all recipes'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { recipes: @recipes_json }, status: 200
      end

      api :GET, '/v1/recipes/:id.json', 'Show recipe info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: { recipe: @recipe }, status: 200
      end

      api :POST, '/v1/recipes.json', 'Create recipe'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        recipe_form = RecipeForm.new(recipe_params)
        if recipe_form.persist?
          render json: { recipe: recipe_form.recipe }, status: 201
        else
          render json: { errors: recipe_form.errors.full_messages }, status: 409
        end
      end

      api :PATCH, '/v1/recipes/:id.json', 'Update recipe'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        recipe_form = RecipeForm.new(@recipe.attributes.merge(recipe_params))
        if recipe_form.persist?
          render json: { recipe: recipe_form.recipe }, status: 200
        else
          render json: { errors: recipe_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/recipes/search.json', 'Search recipes by name with params'
      error code: 401, desc: 'Unauthorized'
      def search
        render json: {
          recipes: ActiveModelSerializers::SerializableResource.new(Recipe.where(id: @recipe_ids), each_serializer: RecipeSerializer).as_json[:recipes]
        }, status: 200
      end

      private

      def find_recipe
        @recipe = Recipe.find_by(id: params[:id])
        render_error('Object is not found') if @recipe.nil?
      end

      def search_recipes
        @recipe_ids = Recipe.search("*#{params[:query]}*", with: define_additional_search_params).map!(&:id)
      end

      def define_additional_search_params(with = {})
        with[:profession_id] = params[:profession_id].to_i if params[:profession_id].present?
        with
      end

      def recipe_params
        h = params.require(:recipe).permit(:skill, name: {}, links: {}, effect_name: {}, effect_links: {}).to_h
        h[:profession] = params[:recipe][:profession_id].present? ? Profession.find_by(id: params[:recipe][:profession_id]) : @recipe&.profession
        h
      end
    end
  end
end
