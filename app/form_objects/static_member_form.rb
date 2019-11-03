# Represents form object for StaticMember model
class StaticMemberForm
  include ActiveModel::Model
  include Virtus.model

  attribute :static, Static
  attribute :character, Character

  validates :static, :character, presence: true
  validate :same_world?
  validate :same_fraction?

  attr_reader :static_member

  def persist?
    return false unless valid?
    return false if exists?
    @static_member = StaticMember.new
    @static_member.attributes = attributes
    @static_member.save
    true
  end

  private

  def exists?
    StaticMember.where(static: static, character: character).exists?
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
