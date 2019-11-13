# Send notifications about coming soon events
class NotifyComingSoonEventsJob < ApplicationJob
  queue_as :default

  def perform
    Notificators::ComingSoonEventsNotificator.call
  end
end
