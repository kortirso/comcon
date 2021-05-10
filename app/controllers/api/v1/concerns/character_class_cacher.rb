# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module CharacterClassCacher
        extend ActiveSupport::Concern

        private

        def get_character_classes_from_cache
          @character_classes = Rails.cache.fetch('character_classes_dependencies') do
            CharacterClass.dependencies
          end
        end
      end
    end
  end
end
