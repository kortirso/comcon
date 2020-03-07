# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module RaceCacher
        extend ActiveSupport::Concern

        private

        def get_races_from_cache
          @races_json = Rails.cache.fetch('race_dependencies_with_fraction') do
            Race.dependencies
          end
        end
      end
    end
  end
end
