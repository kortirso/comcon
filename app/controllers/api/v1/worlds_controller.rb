module Api
  module V1
    class WorldsController < Api::V1::BaseController
      before_action :find_worlds, only: %i[index]

      resource_description do
        short 'World resources'
        formats ['json']
      end

      api :GET, '/v1/worlds.json', 'Get list of worlds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @worlds, status: 200
      end

      private

      def find_worlds
        @worlds = World.order(id: :asc)
      end
    end
  end
end
