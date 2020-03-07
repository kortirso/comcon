# frozen_string_literal: true

module Notifies
  # Notificate about creating bank request
  class CreateBankRequest < Notify
    def call(bank_request:)
      notification = Notification.find_by(event: 'bank_request_creation', status: 1)
      return if notification.nil?
      user_ids = bank_request.bank.guild.bank_users.with_discord_identity.pluck(:id)
      # notify users about guild request
      do_notify(receiver_ids: user_ids, receiver_type: 'User', notification_id: notification.id, content: notification.content(event_object: bank_request))
    end
  end
end
