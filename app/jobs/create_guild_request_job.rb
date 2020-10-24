# frozen_string_literal: true

# Send notifications about creating request to guild
class CreateGuildRequestJob < ApplicationJob
  queue_as :default

  def perform(guild_invite_id:)
    guild_invite = GuildInvite.find_by(id: guild_invite_id)
    return if guild_invite.nil?

    notification = Notification.find_by(event: 'guild_request_creation', status: 0)
    return if notification.nil?

    guild_delivery = Delivery.find_by(deliveriable: guild_invite.guild, notification: notification)
    return if guild_delivery.nil?

    Notifies::CreateGuildRequest.new.call(guild_invite: guild_invite)
  end
end
