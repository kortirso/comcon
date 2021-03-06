# frozen_string_literal: true

module Api
  module V2
    class RecipesController < Api::V1::BaseController
      include Concerns::RecipeCacher

      before_action :is_admin?
      before_action :get_recipes_from_cache, only: %i[index]

      def index
        render json: { recipes: @recipes_json }, status: :ok
      end
    end
  end
end
