# Send notifications about creating request to guild
class CreateGuildRequestJob < ApplicationJob
  queue_as :default

  def perform(guild_invite_id:)
    guild_invite = GuildInvite.find_by(id: guild_invite_id)
    return if guild_invite.nil?
    Notifies::CreateGuildRequest.new.call(guild_invite: guild_invite)
  end
end
