# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module FractionCacher
        extend ActiveSupport::Concern

        private

        def get_fractions_from_cache
          fractions = Fraction.order(id: :asc)
          @fractions_json = Rails.cache.fetch(Fraction.cache_key(fractions, :v1)) do
            ActiveModelSerializers::SerializableResource.new(fractions, each_serializer: FractionSerializer).as_json[:fractions]
          end
        end
      end
    end
  end
end
