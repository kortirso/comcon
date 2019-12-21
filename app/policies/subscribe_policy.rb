# Subscribe policies
class SubscribePolicy < ApplicationPolicy
  authorize :status

  def create?
    return %w[signed unknown rejected].include?(status) && record.is_open? if record.is_a?(Event)
    user.any_static_role?(record)
  end

  def update?
    return event_subscribe_update if record.subscribeable.is_a?(Event)
    static_subscribe_update
  end

  def destroy?
    return record.character.user_id == user.id if record.subscribeable.is_a?(Event)
    false
  end

  private

  def event_subscribe_update
    event = record.subscribeable
    guild_role = event.guild_role_of_user(user.id)
    return true if status == :no_status_change
    # true if raid leader
    return true if !guild_role.nil? && guild_role[0] == 'rl' && %w[approved signed reserve].include?(status)
    # true if class leader and character is the same class
    return true if !guild_role.nil? && guild_role[0] == 'cl' && guild_role[1].include?(record.character.character_class.name['en']) && %w[approved signed reserve].include?(status)
    # true if event owner and only apporoving status
    return true if event.owner.user == user && %w[approved signed reserve].include?(status)
    # false if event is closed
    return false unless event.is_open?
    # true if own character and only signed status
    return true if record.character.user == user && %w[signed unknown rejected].include?(status)
    false
  end

  def static_subscribe_update
    return true if status == :no_status_change
    user.any_static_role?(record.subscribeable)
  end
end
