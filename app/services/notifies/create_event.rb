# frozen_string_literal: true

module Notifies
  # Notify about new event
  class CreateEvent < Notify
    def call(event:)
      if event.eventable_type == 'Guild'
        # guild notification for guild event
        notify_guild(guild_id: event.eventable_id, event_name: 'guild_event_creation', event: event)
        # notify guild users
        notify_users(object: event.eventable, event_name: 'guild_event_creation', event: event)
      elsif event.eventable_type == 'Static'
        if event.eventable.staticable_type == 'Guild'
          # guild notification for guild static event
          notify_guild(guild_id: event.eventable.staticable_id, event_name: 'guild_static_event_creation', event: event)
        end
        # notify static users
        notify_users(object: event.eventable, event_name: 'guild_static_event_creation', event: event)
      end
    end

    private

    def notify_guild(guild_id:, event_name:, event:)
      notification = Notification.find_by(event: event_name, status: 0)
      return if notification.nil?
      do_notify(receiver_ids: guild_id, receiver_type: 'Guild', notification_id: notification.id, content: notification.content(event_object: event))
    end

    def notify_users(object:, event_name:, event:)
      notification = Notification.find_by(event: event_name, status: 1)
      return if notification.nil?
      user_ids = object.users.with_discord_identity.pluck(:id)
      do_notify(receiver_ids: user_ids, receiver_type: 'User', notification_id: notification.id, content: notification.content(event_object: event))
    end
  end
end
