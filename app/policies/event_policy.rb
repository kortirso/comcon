# Event policies
class EventPolicy < ApplicationPolicy
  def show?
    Event.available_for_user(user).pluck(:id).include?(record.id)
  end

  def subscribers?
    show?
  end
end
