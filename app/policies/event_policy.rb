# Event policies
class EventPolicy < ApplicationPolicy
  def show?
    Event.available_for_user(user).pluck(:id).include?(record.id)
  end

  def update?
    record.owner.user_id == user.id
  end

  def destroy?
    update?
  end

  def subscribers?
    show?
  end
end
