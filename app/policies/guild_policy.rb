# Guild policies
class GuildPolicy < ApplicationPolicy
  def management?
    user.any_role?(record.id, 'gm', 'rl')
  end
end
