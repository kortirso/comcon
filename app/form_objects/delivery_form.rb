# Represents form object for Delivery model
class DeliveryForm
  include ActiveModel::Model
  include Virtus.model

  attribute :delivery_type, Integer, default: 0
  attribute :guild, Guild
  attribute :notification, Notification

  validates :delivery_type, :guild, :notification, presence: true

  attr_reader :delivery

  def persist?
    return false unless valid?
    return false if exists?
    @delivery = Delivery.new
    @delivery.attributes = attributes
    @delivery.save
    true
  end

  private

  def exists?
    Delivery.find_by(guild: guild, notification: notification, delivery_type: delivery_type).present?
  end
end
