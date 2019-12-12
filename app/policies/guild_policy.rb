# Guild policies
class GuildPolicy < ApplicationPolicy
  def edit?
    user.any_role?(record.id, 'gm')
  end

  def management?
    user.any_role?(record.id, 'gm', 'rl')
  end

  def bank?
    user.has_characters_in_guild?(guild_id: record.id)
  end

  def bank_management?
    user.any_role?(record.id, 'gm', 'ba')
  end
end
