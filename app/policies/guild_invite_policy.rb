# frozen_string_literal: true

# GuildInvite policies
class GuildInvitePolicy < ApplicationPolicy
  authorize :guild, :character

  def index?
    return user.any_role?(guild.id, 'gm', 'rl') if record == 'true'

    character.user_id == user.id && character.guild_id.nil?
  end

  def create?
    index?
  end

  def destroy?
    index?
  end

  def approve?
    return character.user_id == user.id && character.guild_id.nil? if record == 'true'

    user.any_role?(guild.id, 'gm', 'rl')
  end

  def decline?
    approve?
  end
end
