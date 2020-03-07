# frozen_string_literal: true

# Rebuild guild roles if there is no GM
class RebuildGuildRoles
  include Interactor

  # required context
  # context.guild
  def call
    guild = context.guild
    # if guild has gm - return
    return if guild.guild_roles.where(name: 'gm').exists?
    # if guild has no gm, but has rl
    rls = guild.guild_roles.where(name: 'rl')
    return select_gm_from(rls) unless rls.empty?
    # if guild has no gm/rl, but has cl
    cls = guild.guild_roles.where(name: 'cl')
    return select_gm_from(cls) unless cls.empty?
    guild_members = Character.where(guild_id: guild.id)
    guild_members.empty? ? guild.destroy : CreateGuildRole.call(guild: guild, character: guild_members.sample, name: 'gm')
  end

  private

  def select_gm_from(roles)
    roles.sample.update(name: 'gm')
  end
end
