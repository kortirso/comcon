# Static policies
class StaticPolicy < ApplicationPolicy
  def new?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def show?
    user.any_static_role?(record)
  end

  def create?
    new?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  def management?
    show?
  end
end
