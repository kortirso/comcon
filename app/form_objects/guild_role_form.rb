# Represents form object for GuildRole model
class GuildRoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :guild, Guild
  attribute :character, Character

  validates :name, :guild, :character, presence: true
  validates :name, inclusion: { in: %w[gm rl cl] }

  attr_reader :guild_role

  def persist?
    return false unless valid?
    return false if exists?
    @guild_role = id ? GuildRole.find_by(id: id) : GuildRole.new
    return false if @guild_role.nil?
    @guild_role.attributes = attributes.except(:id)
    @guild_role.save
    true
  end

  private

  def exists?
    guild_roles = id.nil? ? GuildRole.all : GuildRole.where.not(id: id)
    guild_roles.find_by(guild: guild, character: character).present?
  end
end
