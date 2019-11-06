# Delivery policies
class DeliveryPolicy < ApplicationPolicy
  def new?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
