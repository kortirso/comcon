module Api
  module V1
    class DungeonsController < Api::V1::BaseController
      before_action :find_dungeons, only: %i[index]

      resource_description do
        short 'Dungeon resources'
        formats ['json']
      end

      api :GET, '/v1/dungeons.json', 'Get list of dungeons'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @dungeons, status: 200
      end

      private

      def find_dungeons
        @dungeons = Dungeon.order(id: :asc)
      end
    end
  end
end
