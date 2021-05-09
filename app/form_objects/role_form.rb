# frozen_string_literal: true

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
    return errors.add(:name, message: 'Name is not hash') unless name.is_a?(Hash)

    errors.add(:name, message: 'Name EN is empty') if name['en'].blank?
    errors.add(:name, message: 'Name RU is empty') if name['ru'].blank?
  end
end
