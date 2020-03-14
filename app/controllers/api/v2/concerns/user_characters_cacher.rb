# frozen_string_literal: true

module Api
  module V2
    module Concerns
      module UserCharactersCacher
        extend ActiveSupport::Concern

        private

        def get_user_characters_from_cache
          characters = Current.user.characters
          @user_characters_json = Rails.cache.fetch(Character.cache_key_for_user(characters)) do
            FastCharacterSelectSerializer.new(characters).serializable_hash
          end
        end
      end
    end
  end
end
