# frozen_string_literal: true

# Represents form object for Delivery model
class DeliveryForm
  include ActiveModel::Model
  include Virtus.model

  attribute :delivery_type, Integer, default: 0
  attribute :deliveriable_id, Integer
  attribute :deliveriable_type, String
  attribute :notification, Notification

  validates :delivery_type, :deliveriable_id, :deliveriable_type, :notification, presence: true
  validates :deliveriable_type, inclusion: { in: %w[Guild User] }
  validate :deliveriable_exists?
  validate :exists?

  attr_reader :delivery

  def persist?
    return false unless valid?

    @delivery = Delivery.new
    @delivery.attributes = attributes
    @delivery.save
    true
  end

  private

  def deliveriable_exists?
    return if deliveriable_type.blank?
    return if deliveriable_type.constantize.exists?(id: deliveriable_id)

    errors.add(:deliveriable, message: I18n.t('activemodel.errors.models.delivery_form.attributes.deliveriable.is_not_exist'))
  end

  def exists?
    return unless Delivery.exists?(deliveriable_id: deliveriable_id, deliveriable_type: deliveriable_type, notification: notification, delivery_type: delivery_type)

    errors.add(:delivery, message: I18n.t('activemodel.errors.models.delivery_form.attributes.delivery.already_exist'))
  end
end
