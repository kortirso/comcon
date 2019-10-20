module Api
  module V1
    class GuildsController < Api::V1::BaseController
      include Concerns::GuildCacher

      before_action :get_guilds_from_cache, only: %i[index]

      resource_description do
        short 'Guild resources'
        formats ['json']
      end

      api :GET, '/v1/guilds.json', 'Get list of guilds'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { guilds: @guilds_json }, status: 200
      end
    end
  end
end
