# Static policies
class StaticPolicy < ApplicationPolicy
  def new?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def create?
    new?
  end
end
