module Api
  module V1
    module Concerns
      module WorldCacher
        extend ActiveSupport::Concern

        private

        def get_worlds_from_cache
          worlds = World.order(name: :asc)
          @worlds_json = Rails.cache.fetch(World.cache_key(worlds)) do
            ActiveModelSerializers::SerializableResource.new(worlds, each_serializer: WorldSerializer).as_json[:worlds]
          end
        end
      end
    end
  end
end
