# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  def approve?
    record.event.owner.user == user
  end
end
