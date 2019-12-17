module Api
  module V1
    class BanksController < Api::V1::BaseController
      include Concerns::ProfessionCacher
      include Concerns::GameItemCategoryCacher

      before_action :get_professions_from_cache, only: %i[filter_values]
      before_action :get_game_item_categories_from_cache, only: %i[filter_values]

      resource_description do
        short 'Event information resources'
        formats ['json']
      end

      api :GET, '/v1/banks/filter_values.json', 'Values for events filter'
      error code: 401, desc: 'Unauthorized'
      def filter_values
        render json: {
          professions: @professions_json,
          game_item_categories: @game_item_categories_json
        }, status: 200
      end
    end
  end
end
