# Represents form object for GroupRole model
class GroupRoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :value, Hash
  attribute :left_value, Hash
  attribute :groupable_id, Integer
  attribute :groupable_type, String

  validates :value, :left_value, :groupable_id, :groupable_type, presence: true
  validates :groupable_type, inclusion: { in: %w[Event Static] }
  validate :groupable_exists?
  validate :value_as_hash
  validate :left_value_as_hash

  attr_reader :group_role

  def persist?
    self.value = (value.is_a?(Hash) || id ? rebuild_keys_to_integers(value) : GroupRole.default)
    self.left_value = id ? rebuild_keys_to_integers(left_value) : GroupRole.default
    return false unless valid?
    @group_role = id ? GroupRole.find_by(id: id) : GroupRole.new
    return false if @group_role.nil?
    @group_role.attributes = attributes.except(:id)
    @group_role.save
    true
  end

  private

  def groupable_exists?
    return if groupable_type.nil?
    return if groupable_type.constantize.where(id: groupable_id).exists?
    errors[:groupable] << 'is not exists'
  end

  def value_as_hash
    errors[:value] << 'Value is not hash' unless value.is_a?(Hash)
  end

  def left_value_as_hash
    errors[:left_value] << 'Left value is not hash' unless left_value.is_a?(Hash)
  end

  def rebuild_keys_to_integers(input)
    return unless input.is_a?(Hash)
    input.map { |key, value| [key, value.is_a?(Hash) ? rebuild_keys_to_integers(value) : value.to_i] }.to_h
  end
end
