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
        render json: {
          guilds: ActiveModelSerializers::SerializableResource.new(@guilds, each_serializer: GuildSerializer).as_json[:guilds]
        }, status: 200
      end

      private

      def find_guilds
        @guilds = Guild.order(name: :asc).includes(:fraction, :world)
        @guilds = @guilds.where(world_id: params[:world_id]) if params[:world_id].present?
        @guilds = @guilds.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
      end
    end
  end
end
