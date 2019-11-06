module Api
  module V1
    module Concerns
      module NotificationCacher
        extend ActiveSupport::Concern

        private

        def get_notifications_from_cache
          notifications = Notification.order(id: :asc)
          @notifications_json = Rails.cache.fetch(Notification.cache_key(notifications)) do
            ActiveModelSerializers::SerializableResource.new(notifications, each_serializer: NotificationSerializer).as_json[:notifications]
          end
        end
      end
    end
  end
end
