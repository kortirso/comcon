# frozen_string_literal: true

module Api
  module V1
    class RolesController < Api::V1::BaseController
      before_action :find_roles, only: %i[index]

      def index
        render json: @roles, status: :ok
      end

      private

      def find_roles
        @roles = Role.order(id: :asc)
      end
    end
  end
end
