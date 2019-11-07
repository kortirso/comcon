# GuildInvite policies
class GuildInvitePolicy < ApplicationPolicy
  authorize :guild, :character

  def new?
    return user.any_role?(guild.id, 'gm', 'rl') if record == 'true'
    character.user_id == user.id && character.guild_id.nil?
  end

  def create?
    new?
  end

  def destroy?
    new?
  end
end
