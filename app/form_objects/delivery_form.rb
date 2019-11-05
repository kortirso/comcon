# Represents form object for Delivery model
class DeliveryForm
  include ActiveModel::Model
  include Virtus.model

  attribute :delivery_type, Integer, default: 0
  attribute :deliveriable_id, Integer
  attribute :deliveriable_type, String
  attribute :notification, Notification

  validates :delivery_type, :deliveriable_id, :deliveriable_type, :notification, presence: true
  validates :deliveriable_type, inclusion: { in: %w[Guild] }

  attr_reader :delivery

  def persist?
    return false unless valid?
    return false unless deliveriable_exists?
    return false if exists?
    @delivery = Delivery.new
    @delivery.attributes = attributes
    @delivery.save
    true
  end

  private

  def deliveriable_exists?
    deliveriable_type.constantize.where(id: deliveriable_id).exists?
  end

  def exists?
    Delivery.where(deliveriable_id: deliveriable_id, deliveriable_type: deliveriable_type, notification: notification, delivery_type: delivery_type).exists?
  end
end
