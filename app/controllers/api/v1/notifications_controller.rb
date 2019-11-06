module Api
  module V1
    class NotificationsController < Api::V1::BaseController
      include Concerns::NotificationCacher

      before_action :get_notifications_from_cache, only: %i[index]

      resource_description do
        short 'Notification resources'
        formats ['json']
      end

      api :GET, '/v1/notifications.json', 'Get list of notifications'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: { notifications: @notifications_json }, status: 200
      end
    end
  end
end
