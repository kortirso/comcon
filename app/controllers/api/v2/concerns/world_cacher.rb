module Api
  module V2
    module Concerns
      module WorldCacher
        extend ActiveSupport::Concern

        private

        def get_worlds_from_cache
          worlds = World.order(zone: :asc, name: :asc)
          @worlds_json = Rails.cache.fetch(World.cache_key(worlds)) do
            Fast::WorldSerializer.new(worlds).serializable_hash
          end
        end
      end
    end
  end
end
