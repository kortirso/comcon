# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  authorize :status

  def update?
    record.event.owner.user == user || record.character.user == user && %w[signed unknown rejected].include?(status)
  end
end
