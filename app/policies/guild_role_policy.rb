# GuildRole policies
class GuildRolePolicy < ApplicationPolicy
  def create?
    admin? || user.characters.where(guild_id: record.id).has_guild_master?
  end

  def update?
    admin? || user.characters.where(guild_id: record.guild_id).has_guild_master?
  end

  def destroy?
    update?
  end
end
