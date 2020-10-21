# frozen_string_literal: true

module Api
  module V1
    class ProfessionsController < Api::V1::BaseController
      include Concerns::ProfessionCacher

      before_action :get_professions_from_cache, only: %i[index]

      def index
        render json: { professions: @professions_json }, status: :ok
      end
    end
  end
end
