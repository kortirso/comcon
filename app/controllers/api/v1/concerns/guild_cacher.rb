module Api
  module V1
    module Concerns
      module GuildCacher
        extend ActiveSupport::Concern

        private

        def get_guilds_from_cache
          guilds = Guild.order(id: :asc).includes(:fraction, :world)
          @guilds_json = Rails.cache.fetch(Guild.cache_key(guilds)) do
            ActiveModelSerializers::SerializableResource.new(guilds.includes(:fraction, :world), each_serializer: GuildSerializer).as_json[:guilds]
          end
        end
      end
    end
  end
end
