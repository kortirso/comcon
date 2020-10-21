# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < Api::V1::BaseController
      include Concerns::NotificationCacher

      before_action :get_notifications_from_cache, only: %i[index]

      def index
        render json: { notifications: @notifications_json }, status: :ok
      end
    end
  end
end
