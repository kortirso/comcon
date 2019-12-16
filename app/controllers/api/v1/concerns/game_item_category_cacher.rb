module Api
  module V1
    module Concerns
      module GameItemCategoryCacher
        extend ActiveSupport::Concern

        private

        def get_game_item_categories_from_cache
          game_item_categories = GameItemCategory.order(id: :asc)
          @game_item_categories_json = Rails.cache.fetch(GameItemCategory.cache_key(game_item_categories)) do
            GameItemCategory.dependencies
          end
        end
      end
    end
  end
end
