# frozen_string_literal: true

module Api
  module V1
    class WorldsController < Api::V1::BaseController
      include Concerns::WorldCacher

      before_action :get_worlds_from_cache, only: %i[index]

      resource_description do
        short 'World resources'
        formats ['json']
      end

      api :GET, '/v1/worlds.json', 'Get list of worlds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { worlds: @worlds_json }, status: :ok
      end
    end
  end
end
