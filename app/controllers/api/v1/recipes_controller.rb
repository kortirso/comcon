module Api
  module V1
    class RecipesController < Api::V1::BaseController
      before_action :is_admin?
      before_action :find_recipes, only: %i[index]
      before_action :find_recipe, only: %i[show update]

      resource_description do
        short 'Recipe resources'
        formats ['json']
      end

      api :GET, '/v1/recipes.json', 'Get all recipes'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @recipes, status: 200
      end

      api :GET, '/v1/recipes/:id.json', 'Show recipe info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: @recipe, status: 200
      end

      api :POST, '/v1/recipes.json', 'Create recipe'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        recipe_form = RecipeForm.new(recipe_params)
        if recipe_form.persist?
          render json: recipe_form.recipe, status: 201
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
          render json: recipe_form.recipe, status: 200
        else
          render json: { errors: recipe_form.errors.full_messages }, status: 409
        end
      end

      private

      def find_recipes
        @recipes = Recipe.order(skill: :desc)
        @recipes = @recipes.where(profession_id: params[:profession_id]) if params[:profession_id].present?
      end

      def find_recipe
        @recipe = Recipe.find_by(id: params[:id])
        render_error('Object is not found') if @recipe.nil?
      end

      def recipe_params
        h = params.require(:recipe).permit(:skill, name: {}, links: {}).to_h
        h[:profession] = params[:recipe][:profession_id].present? ? Profession.find_by(id: params[:recipe][:profession_id]) : @recipe&.profession
        h
      end
    end
  end
end
