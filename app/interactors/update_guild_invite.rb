# frozen_string_literal: true

# Update GuildInvite
class UpdateGuildInvite
  include Interactor

  # required context
  # context.guild_invite
  # context.status
  def call
    guild_invite = context.guild_invite
    guild_invite_form = GuildInviteForm.new(guild_invite.attributes.merge(guild: guild_invite.guild, character: guild_invite.character, status: context.status))
    context.fail!(message: guild_invite_form.errors.full_messages) unless guild_invite_form.persist?
  end
end
