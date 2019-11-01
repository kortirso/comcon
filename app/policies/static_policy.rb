# Static policies
class StaticPolicy < ApplicationPolicy
  def new?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def show?
    return true if record.staticable_type == 'Guild' && user.any_role?(record.staticable_id, 'gm', 'rl')
    return true if record.staticable_type == 'Character' && user.characters.pluck(:id).include?(record.staticable_id)
    false
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
end
