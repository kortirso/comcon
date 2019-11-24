# Guild policies
class GuildPolicy < ApplicationPolicy
  def edit?
    user.any_role?(record.id, 'gm')
  end

  def management?
    user.any_role?(record.id, 'gm', 'rl')
  end
end
