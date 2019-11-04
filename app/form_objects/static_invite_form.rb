# Represents form object for StaticInvite model
class StaticInviteForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :static, Static
  attribute :character, Character
  attribute :status, Integer, default: 0

  validates :static, :character, presence: true
  validates :status, inclusion: 0..2
  validate :status_value
  validate :same_world?
  validate :same_fraction?

  attr_reader :static_invite

  def persist?
    return false unless valid?
    return false if exists?
    @static_invite = id ? StaticInvite.find_by(id: id) : StaticInvite.new
    return false if @static_invite.nil?
    @static_invite.attributes = attributes.except(:id)
    @static_invite.save
    true
  end

  private

  def exists?
    static_invites = id.nil? ? StaticInvite.all : StaticInvite.where.not(id: id)
    static_invites.where(static: static, character: character).exists?
  end

  def status_value
    return if id && !status.zero?
    return if id.nil? && status.zero?
    errors[:status] << 'not valid'
  end

  def same_world?
    return if static.nil? || character.nil?
    return if static.world_id == character.world_id
    errors[:worlds] << 'are different'
  end

  def same_fraction?
    return if static.nil? || character.nil?
    return if static.fraction_id == character.race.fraction_id
    errors[:fractions] << 'are different'
  end
end
