# frozen_string_literal: true

# Delete guild role
class RemoveGuildRole
  include Interactor

  # required context
  # context.guild
  # context.character
  def call
    guild_role = GuildRole.find_by(guild: context.guild, character: context.character)
    guild_role.destroy if guild_role.present?
    context.character.update(guild_id: nil)
  end
end
