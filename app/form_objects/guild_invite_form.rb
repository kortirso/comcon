# Represents form object for GuildInvite model
class GuildInviteForm
  include ActiveModel::Model
  include Virtus.model

  attribute :from_guild, Boolean, default: false
  attribute :guild, Guild
  attribute :character, Character

  validates :guild, :character, presence: true
  validate :guild_invite_exists?
  validate :character_not_in_guild?

  attr_reader :guild_invite

  def persist?
    return false unless valid?
    @guild_invite = GuildInvite.new
    @guild_invite.attributes = attributes.except(:id)
    @guild_invite.save
    true
  end

  private

  def guild_invite_exists?
    return unless GuildInvite.all.where(guild: guild, character: character, from_guild: from_guild).exists?
    errors[:guild_invite] << 'already exists'
  end

  def character_not_in_guild?
    return if character.nil? || guild.nil?
    return if character.guild_id != guild.id
    errors[:character] << 'is already in the guild'
  end
end
