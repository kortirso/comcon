# Delivery policies
class DeliveryPolicy < ApplicationPolicy
  def new?
    return user.any_role?(record.id, 'gm', 'rl') if record.is_a?(Guild)
    true
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
