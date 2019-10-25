module Api
  module V1
    class FractionsController < Api::V1::BaseController
      include Concerns::FractionCacher

      before_action :get_fractions_from_cache, only: %i[index]

      resource_description do
        short 'Fraction resources'
        formats ['json']
      end

      api :GET, '/v1/fractions.json', 'Get list of fractions'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { fractions: @fractions_json }, status: 200
      end
    end
  end
end
