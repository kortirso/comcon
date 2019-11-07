# Represents form object for GuildInvite model
class GuildInviteForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :from_guild, Boolean, default: false
  attribute :guild, Guild
  attribute :character, Character
  attribute :status, Integer, default: 0

  validates :status, :guild, :character, presence: true
  validates :status, inclusion: 0..1
  validate :status_value
  validate :guild_invite_exists?
  validate :character_not_in_guild?

  attr_reader :guild_invite

  def persist?
    return false unless valid?
    @guild_invite = id ? GuildInvite.find_by(id: id) : GuildInvite.new
    return false if @guild_invite.nil?
    @guild_invite.attributes = attributes.except(:id)
    @guild_invite.save
    true
  end

  private

  def status_value
    return if id && !status.zero?
    return if id.nil? && status.zero?
    errors[:status] << 'not valid'
  end

  def guild_invite_exists?
    guild_invites = id.nil? ? GuildInvite.all : GuildInvite.where.not(id: id)
    return unless guild_invites.where(guild: guild, character: character, from_guild: from_guild).exists?
    errors[:guild_invite] << 'already exists'
  end

  def character_not_in_guild?
    return if character.nil? || guild.nil?
    return if character.guild_id != guild.id
    errors[:character] << 'is already in the guild'
  end
end
