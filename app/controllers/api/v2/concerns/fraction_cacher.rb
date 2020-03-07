# frozen_string_literal: true

module Api
  module V2
    module Concerns
      module FractionCacher
        extend ActiveSupport::Concern

        private

        def get_fractions_from_cache
          fractions = Fraction.order(id: :asc)
          @fractions_json = Rails.cache.fetch(Fraction.cache_key(fractions, :v2)) do
            FastFractionSerializer.new(fractions).serializable_hash
          end
        end
      end
    end
  end
end
