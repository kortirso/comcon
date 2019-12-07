# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  authorize :status

  def create?
    return %w[signed unknown rejected].include?(status) && record.is_open? if record.is_a?(Event)
    user.any_static_role?(record)
  end

  def update?
    return event_subscribe_update if record.subscribeable.is_a?(Event)
    user.any_static_role?(record.subscribeable)
  end

  private

  def event_subscribe_update
    event = record.subscribeable
    return true if status == :no_status_change
    # true if raid owner
    return true if event.owner.user == user && %w[approved signed reserve].include?(status)
    # false if event is closed
    return false unless event.is_open?
    # true if own character
    return true if record.character.user == user && %w[signed unknown rejected].include?(status)
    # false if not approving status
    return false unless %w[approved signed reserve].include?(status)
    # false if no guild role
    guild_role = event.guild_role_of_user(user.id)
    return false if guild_role.nil?
    # true if raid leader
    return true if guild_role[0] == 'rl'
    # true if class leader and character is the same class
    return true if guild_role[0] == 'cl' && guild_role[1].include?(record.character.character_class.name['en'])
    false
  end
end
