# frozen_string_literal: true

module Api
  module V1
    class RecipesController < Api::V1::BaseController
      include Concerns::RecipeCacher

      before_action :is_admin?, except: %i[search]
      before_action :get_recipes_from_cache, only: %i[index]
      before_action :find_recipe, only: %i[show update]
      before_action :search_recipes, only: %i[search]

      def index
        render json: { recipes: @recipes_json }, status: :ok
      end

      def show
        render json: { recipe: @recipe }, status: :ok
      end

      def create
        recipe_form = RecipeForm.new(recipe_params)
        if recipe_form.persist?
          render json: { recipe: recipe_form.recipe }, status: :created
        else
          render json: { errors: recipe_form.errors.full_messages }, status: :conflict
        end
      end

      def update
        recipe_form = RecipeForm.new(@recipe.attributes.merge(recipe_params))
        if recipe_form.persist?
          render json: { recipe: recipe_form.recipe }, status: :ok
        else
          render json: { errors: recipe_form.errors.full_messages }, status: :conflict
        end
      end

      def search
        render json: {
          recipes: ActiveModelSerializers::SerializableResource.new(Recipe.where(id: @recipe_ids), each_serializer: RecipeSerializer).as_json[:recipes]
        }, status: :ok
      end

      private

      def find_recipe
        @recipe = Recipe.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @recipe.nil?
      end

      def search_recipes
        @recipe_ids = Recipe.search("*#{params[:query]}*", with: define_additional_search_params).map!(&:id)
      end

      def define_additional_search_params(with={})
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
