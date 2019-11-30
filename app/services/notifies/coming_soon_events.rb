module Notifies
  # Notificate about coming soon events
  class ComingSoonEvents < Notify
    def call
      current_time = DateTime.now.utc + 30.minutes
      Event.where('start_time > ? AND start_time <= ?', current_time, current_time + 10.minutes).each do |event|
        notify_about_event(event: event)
      end
    end

    private

    def notify_about_event(event:)
      notification = Notification.find_by(event: 'event_start_soon', status: 1)
      user_ids = event.signed_users.with_discord_identity.pluck(:id)
      # notify users about soon event
      do_notify(receiver_ids: user_ids, receiver_type: 'User', notification_id: notification.id, content: notification.content(event: event))
    end
  end
end
