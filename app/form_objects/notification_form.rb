# frozen_string_literal: true

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
    return unless Notification.exists?(event: event, status: status)

    errors.add(:notification, message: 'is already exists')
  end

  def name_as_hash
    return errors.add(:name, message: 'Name is not hash') unless name.is_a?(Hash)

    errors.add(:name, message: 'Name EN is empty') if name['en'].blank?
    errors.add(:name, message: 'Name RU is empty') if name['ru'].blank?
  end
end
