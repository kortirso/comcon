# frozen_string_literal: true

# Send notifications about coming soon events
class NotifyComingSoonEventsJob < ApplicationJob
  queue_as :default

  def perform
    Notifies::ComingSoonEvents.new.call
  end
end
