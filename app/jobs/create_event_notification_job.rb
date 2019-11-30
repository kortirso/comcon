# Send notifications about creating events
class CreateEventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id:)
    event = Event.find_by(id: event_id)
    return if event.nil?
    if event.eventable_type == 'Guild'
      Notificators::CreateEventNotificator.call(event_id: event_id)
    elsif event.eventable_type == 'Static' && event.eventable.staticable_type == 'Guild'
      Notificators::CreateEventForGuildStaticNotificator.call(event_id: event_id)
    end
  end
end
