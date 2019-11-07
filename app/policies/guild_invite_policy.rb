# GuildInvite policies
class GuildInvitePolicy < ApplicationPolicy
  def new?
    return user.any_role?(record.id, 'gm', 'rl') if record.is_a?(Guild)
    true
  end
end
