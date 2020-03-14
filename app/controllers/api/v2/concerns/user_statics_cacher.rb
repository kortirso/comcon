# frozen_string_literal: true

module Api
  module V2
    module Concerns
      module UserStaticsCacher
        extend ActiveSupport::Concern

        private

        def get_user_statics_from_cache
          statics = Current.user.statics
          @user_statics_json = Rails.cache.fetch(Static.cache_key_for_user(statics, Current.user.id)) do
            FastStaticSelectSerializer.new(statics).serializable_hash
          end
        end
      end
    end
  end
end
