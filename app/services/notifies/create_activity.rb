# frozen_string_literal: true

module Notifies
  # Notify about new event
  class CreateActivity < Notify
    def call(activity:)
      # guild notification for activity event
      notify_guild(guild_id: activity.guild_id, event_name: 'activity_creation', activity: activity)
      # notify guild users
      notify_users(object: activity.guild, event_name: 'activity_creation', activity: activity)
    end

    private

    def notify_guild(guild_id:, event_name:, activity:)
      notification = Notification.find_by(event: event_name, status: 0)
      return if notification.nil?

      do_notify(receiver_ids: guild_id, receiver_type: 'Guild', notification_id: notification.id, content: notification.content(event_object: activity))
    end

    def notify_users(object:, event_name:, activity:)
      notification = Notification.find_by(event: event_name, status: 1)
      return if notification.nil?

      user_ids = object.users.with_discord_identity.pluck(:id)
      do_notify(receiver_ids: user_ids, receiver_type: 'User', notification_id: notification.id, content: notification.content(event_object: activity))
    end
  end
end
