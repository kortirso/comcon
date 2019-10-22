# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  authorize :status

  def create?
    %w[signed unknown rejected].include?(status) && record.is_open?
  end

  def update?
    record.event.owner.user == user && %w[approved signed].include?(status) || record.character.user == user && %w[signed unknown rejected].include?(status) && record.event.is_open?
  end
end
