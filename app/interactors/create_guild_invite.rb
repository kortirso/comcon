# Create GuildInvite
class CreateGuildInvite
  include Interactor

  # required context
  # context.guild
  # context.character
  # context.from_guild
  def call
    return if context.guild.nil?
    check_twinks
    return if context.guild_invite == { result: 'Approved' }
    guild_invite_form = GuildInviteForm.new(guild: context.guild, character: context.character, from_guild: ['true', true].include?(context.from_guild))
    if guild_invite_form.persist?
      context.guild_invite = guild_invite_form.guild_invite
      CreateGuildRequestJob.perform_now(guild_invite_id: guild_invite_form.guild_invite.id)
    else
      context.fail!(message: guild_invite_form.errors.full_messages)
    end
  end

  private

  def check_twinks
    return if ['true', true].include?(context.from_guild)
    if context.character.user.has_characters_in_guild?(guild_id: context.guild.id)
      context.character.update(guild_id: context.guild.id)
      context.guild_invite = { result: 'Approved' }
      context.character.guild_invites.destroy_all
    end
  end
end
