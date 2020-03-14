# frozen_string_literal: true

module Api
  module V2
    module Concerns
      module UserGuildsCacher
        extend ActiveSupport::Concern

        private

        def get_user_guilds_from_cache
          guilds = Current.user.guilds
          @user_guilds_json = Rails.cache.fetch(Guild.cache_key_for_user(guilds, Current.user.id)) do
            FastGuildSelectSerializer.new(guilds).serializable_hash
          end
        end
      end
    end
  end
end
