# Represents form object for GroupRole model
class GroupRoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :value, Hash, default: GroupRole.default
  attribute :groupable_id, Integer
  attribute :groupable_type, String

  validates :value, :groupable_id, :groupable_type, presence: true
  validates :groupable_type, inclusion: { in: %w[Event] }
  validate :groupable_exists?
  validate :value_as_hash

  attr_reader :group_role

  def persist?
    return false unless valid?
    self.value = rebuild_keys_to_integers(value)
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

  def rebuild_keys_to_integers(input)
    input.map { |key, value| [key, value.is_a?(Hash) ? rebuild_keys_to_integers(value) : value.to_i] }.to_h
  end
end
