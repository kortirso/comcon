# frozen_string_literal: true

# Send notifications about creating events
class CreateEventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id:)
    event = Event.find_by(id: event_id)
    return if event.nil?

    Notifies::CreateEvent.new.call(event: event)
  end
end
