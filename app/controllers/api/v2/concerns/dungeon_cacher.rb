# frozen_string_literal: true

module Api
  module V2
    module Concerns
      module DungeonCacher
        extend ActiveSupport::Concern

        private

        def get_dungeons_for_select_from_cache
          dungeons = Dungeon.order(id: :asc)
          @dungeons_json = Rails.cache.fetch(Dungeon.cache_key(dungeons, :v2)) do
            FastDungeonSelectSerializer.new(dungeons).serializable_hash
          end
        end
      end
    end
  end
end
