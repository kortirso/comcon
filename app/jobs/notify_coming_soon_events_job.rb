# Send notifications about coming soon events
class NotifyComingSoonEventsJob < ApplicationJob
  queue_as :default

  def perform
    Notificators::Users::ComingSoonEventsNotificator.call
  end
end
