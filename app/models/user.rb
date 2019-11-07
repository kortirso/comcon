# Represents users in the system
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :characters, dependent: :destroy
  has_many :guilds, -> { distinct }, through: :characters

  validates :role, presence: true, inclusion: { in: %w[user admin] }

  # has characters of user any role in guild?
  def any_role?(guild_id, *allowed_roles)
    character_ids = Character.where(user_id: id, guild_id: guild_id).pluck(:id)
    GuildRole.where(guild_id: guild_id, character_id: character_ids, name: allowed_roles).exists?
  end

  def any_static_role?(static)
    return true if static.staticable_type == 'Guild' && any_role?(static.staticable_id, 'gm', 'rl')
    return true if static.staticable_type == 'Character' && characters.pluck(:id).include?(static.staticable_id)
    false
  end

  def statics
    character_ids = Character.where(user_id: id).pluck(:id)
    static_ids = StaticMember.where(character_id: character_ids).pluck(:static_id)
    Static.where(id: static_ids)
  end

  def static_invites
    character_ids = Character.where(user_id: id).pluck(:id)
    StaticInvite.where(character_id: character_ids, status: 0)
  end

  def guild_invites
    character_ids = Character.where(user_id: id).pluck(:id)
    GuildInvite.where(character_id: character_ids, status: 0, from_guild: true)
  end

  def is_admin?
    role == 'admin'
  end
end
