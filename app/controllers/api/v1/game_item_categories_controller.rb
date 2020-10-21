# frozen_string_literal: true

module Api
  module V1
    class GameItemCategoriesController < Api::V1::BaseController
      include Concerns::GameItemCategoryCacher

      before_action :get_game_item_categories_from_cache, only: %i[index]

      def index
        render json: @game_item_categories_json, status: :ok
      end
    end
  end
end
