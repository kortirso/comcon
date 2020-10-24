# frozen_string_literal: true

module Api
  module V1
    class RacesController < Api::V1::BaseController
      before_action :find_races, only: %i[index]

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
