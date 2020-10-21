# frozen_string_literal: true

module Api
  module V1
    class FractionsController < Api::V1::BaseController
      include Concerns::FractionCacher

      before_action :get_fractions_from_cache, only: %i[index]

      def index
        render json: { fractions: @fractions_json }, status: :ok
      end
    end
  end
end
