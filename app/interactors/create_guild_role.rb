# frozen_string_literal: true

# Create GuildRole
class CreateGuildRole
  include Interactor

  # required context
  # context.guild
  # context.character
  # context.name
  def call
    guild_role_form = GuildRoleForm.new(guild: context.guild, character: context.character, name: context.name)
    if guild_role_form.persist?
      context.guild_role = guild_role_form.guild_role
    else
      context.fail!(message: guild_role_form.errors.full_messages)
    end
  end
end
