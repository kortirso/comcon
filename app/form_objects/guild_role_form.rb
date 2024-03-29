# frozen_string_literal: true

# Represents form object for GuildRole model
class GuildRoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :guild, Guild
  attribute :character, Character

  validates :name, :guild, :character, presence: true
  validates :name, inclusion: { in: %w[gm rl cl ba] }
  validate :character_in_guild?
  validate :guild_role_exists?

  attr_reader :guild_role

  def persist?
    return false unless valid?

    @guild_role = id ? GuildRole.find_by(id: id) : GuildRole.new
    return false if @guild_role.nil?

    @guild_role.attributes = attributes.except(:id)
    @guild_role.save
    true
  end

  private

  def guild_role_exists?
    guild_roles = id.nil? ? GuildRole.all : GuildRole.where.not(id: id)
    return unless guild_roles.exists?(guild: guild, character: character)

    errors.add(:guild_role, message: 'already exists')
  end

  def character_in_guild?
    return if character.nil? || guild.nil?
    return if character.guild_id == guild.id

    errors.add(:character, message: 'is not in the guild')
  end
end
