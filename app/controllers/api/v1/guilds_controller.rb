module Api
  module V1
    class GuildsController < Api::V1::BaseController
      before_action :find_guilds, only: %i[index]

      resource_description do
        short 'Guild resources'
        formats ['json']
      end

      api :GET, '/v1/guilds.json', 'Get list of guilds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @guilds, status: 200
      end

      private

      def find_guilds
        @guilds = Guild.order(id: :asc).includes(:fraction, :world)
      end
    end
  end
end
