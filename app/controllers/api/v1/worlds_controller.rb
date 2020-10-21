# frozen_string_literal: true

module Api
  module V1
    class WorldsController < Api::V1::BaseController
      include Concerns::WorldCacher

      before_action :get_worlds_from_cache, only: %i[index]

      def index
        render json: { worlds: @worlds_json }, status: :ok
      end
    end
  end
end
