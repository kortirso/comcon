# Represents form object for Notification model
class NotificationForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash
  attribute :event, String
  attribute :status, Integer, default: 0

  validates :status, :name, :event, presence: true
  validates :status, inclusion: 0..2
  validate :name_as_hash
  validate :exists?

  attr_reader :notification

  def persist?
    return false unless valid?
    @notification = Notification.new
    @notification.attributes = attributes
    @notification.save
    true
  end

  private

  def exists?
    return unless Notification.where(event: event, status: status).exists?
    errors[:notification] << 'is already exists'
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
