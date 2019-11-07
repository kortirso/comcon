# Create GuildInvite
class CreateGuildInvite
  include Interactor

  # required context
  # context.guild
  # context.character
  # context.from_guild
  def call
    guild_invite_form = GuildInviteForm.new(guild: context.guild, character: context.character, from_guild: context.from_guild)
    if guild_invite_form.persist?
      context.guild_invite = guild_invite_form.guild_invite
    else
      context.fail!(message: guild_invite_form.errors.full_messages)
    end
  end
end
