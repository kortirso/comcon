# Send notifications about creating events
class CreateEventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id:)
    Notificators::CreateEventNotificator.call(event_id: event_id)
  end
end
