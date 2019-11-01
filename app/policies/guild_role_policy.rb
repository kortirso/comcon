# GuildRole policies
class GuildRolePolicy < ApplicationPolicy
  def create?
    admin? || user.any_role?(record.id, 'gm', 'rl')
  end

  def update?
    admin? || user.any_role?(record.guild_id, 'gm', 'rl')
  end

  def destroy?
    update?
  end
end
