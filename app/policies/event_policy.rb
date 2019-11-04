# Event policies
class EventPolicy < ApplicationPolicy
  def show?
    Event.available_for_user(user).pluck(:id).include?(record.id)
  end

  def edit?
    record.owner.user_id == user.id
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def subscribers?
    show?
  end
end
