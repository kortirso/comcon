# Represents form object for Role model
class RoleForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash

  validates :name, presence: true
  validate :name_as_hash

  attr_reader :role

  def persist?
    return false unless valid?
    return false if exists?
    @role = Role.new
    @role.attributes = attributes
    @role.save
    true
  end

  private

  def exists?
    Role.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
