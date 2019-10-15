# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  def create?
    record.character.user == user
  end

  def update?
    record.event.owner.user == user || create?
  end
end
