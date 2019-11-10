# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  authorize :status

  def create?
    %w[signed unknown rejected].include?(status) && record.is_open?
  end

  def update?
    return true if status == :no_status_change
    # true if raid owner
    return true if record.event.owner.user == user && %w[approved signed].include?(status)
    # false if event is closed
    return false unless record.event.is_open?
    # true if own character
    return true if record.character.user == user && %w[signed unknown rejected].include?(status)
    # false if not guild event
    return false if record.event.eventable_type != 'Guild'
    # false if not approving status
    return false unless %w[approved signed].include?(status)
    # false if no guild role
    guild_role = record.event.guild_role_of_user(user.id)
    return false if guild_role.nil?
    # true if raid leader
    return true if guild_role[0] == 'rl'
    # true if class leader and character is the same class
    return true if guild_role[0] == 'cl' && guild_role[1].include?(record.character.character_class.name['en'])
    false
  end
end
