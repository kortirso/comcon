class RecipesController < ApplicationController
  before_action :is_admin?
  before_action :find_recipe, only: %i[edit destroy]

  def index; end

  def new; end

  def edit; end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, status: 303
  end

  private

  def find_recipe
    @recipe = Recipe.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @recipe.nil?
  end
end
