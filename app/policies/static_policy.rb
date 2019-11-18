# Static policies
class StaticPolicy < ApplicationPolicy
  def show?
    user.any_static_role?(record) || !record.privy? || user.any_character_in_static?(record)
  end

  def new?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def edit?
    user.any_static_role?(record)
  end
end
