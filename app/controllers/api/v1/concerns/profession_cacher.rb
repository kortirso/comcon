module Api
  module V1
    module Concerns
      module ProfessionCacher
        extend ActiveSupport::Concern

        private

        def get_professions_from_cache
          professions = Profession.order(id: :asc)
          @professions_json = Rails.cache.fetch(Profession.cache_key(professions)) do
            ActiveModelSerializers::SerializableResource.new(professions, each_serializer: ProfessionSerializer).as_json[:professions]
          end
        end
      end
    end
  end
end
