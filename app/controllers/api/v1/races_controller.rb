# frozen_string_literal: true

module Api
  module V1
    class RacesController < Api::V1::BaseController
      before_action :find_races, only: %i[index]

      resource_description do
        short 'Race resources'
        formats ['json']
      end

      api :GET, '/v1/races.json', 'Get list of races'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: @races, status: :ok
      end

      private

      def find_races
        @races = Race.order(id: :asc)
      end
    end
  end
end
