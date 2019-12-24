module Api
  module V1
    module Concerns
      module DungeonCacher
        extend ActiveSupport::Concern

        private

        def get_dungeons_from_cache
          dungeons = Dungeon.order(id: :asc)
          @dungeons_json = Rails.cache.fetch(Dungeon.cache_key(dungeons, :v1)) do
            ActiveModelSerializers::SerializableResource.new(dungeons, each_serializer: DungeonSerializer).as_json[:dungeons]
          end
        end
      end
    end
  end
end
