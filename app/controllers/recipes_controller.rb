# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :is_admin?
  before_action :find_recipe, only: %i[edit destroy]
  before_action :allow_wowhead_script, only: %i[index]

  def index; end

  def new; end

  def edit; end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, status: :see_other
  end

  private

  def find_recipe
    @recipe = Recipe.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @recipe.nil?
  end
end
