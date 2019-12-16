module Notifies
  # Notificate about creating guild request
  class CreateGuildRequest < Notify
    def call(guild_invite:)
      notification = Notification.find_by(event: 'guild_request_creation', status: 1)
      return if notification.nil?
      user_ids = guild_invite.guild.head_users.with_discord_identity.pluck(:id)
      # notify users about guild request
      do_notify(receiver_ids: user_ids, receiver_type: 'User', notification_id: notification.id, content: notification.content(event_object: guild_invite))
    end
  end
end
