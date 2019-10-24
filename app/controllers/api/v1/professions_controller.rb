module Api
  module V1
    class ProfessionsController < Api::V1::BaseController
      include Concerns::ProfessionCacher

      before_action :get_professions_from_cache, only: %i[index]

      resource_description do
        short 'Profession resources'
        formats ['json']
      end

      api :GET, '/v1/professions.json', 'Get list of professions'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { professions: @professions_json }, status: 200
      end
    end
  end
end
