# frozen_string_literal: true

module Api
  module V1
    class DungeonsController < Api::V1::BaseController
      include Concerns::DungeonCacher

      before_action :get_dungeons_from_cache, only: %i[index]

      resource_description do
        short 'Dungeon resources'
        formats ['json']
      end

      api :GET, '/v1/dungeons.json', 'Get list of dungeons'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { dungeons: @dungeons_json }, status: :ok
      end
    end
  end
end
