# Represents form object for DeliveryParam model
class DeliveryParamForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :params, Hash
  attribute :delivery, Delivery

  validates :params, :delivery, presence: true
  validate :params_for_delivery_type

  attr_reader :delivery_param

  def persist?
    return false unless valid?
    return false if exists?
    @delivery_param = id ? DeliveryParam.find_by(id: id) : DeliveryParam.new
    return false if @delivery_param.nil?
    @delivery_param.attributes = attributes.except(:id)
    @delivery_param.save
    true
  end

  private

  def exists?
    delivery_params = id.nil? ? DeliveryParam.all : DeliveryParam.where.not(id: id)
    delivery_params.find_by(delivery: delivery).present?
  end

  def params_for_delivery_type
    return if delivery.nil?
    case delivery.delivery_type
      when 'discord_webhook' then check_discord_webhook_params
      else true
    end
  end

  def check_discord_webhook_params
    return errors[:params] << 'Discord webhook params is not hash' unless params.is_a?(Hash)
    errors[:params] << 'Discord webhook params ID is invalid' if !params['id'].present? || !params['id'].is_a?(Integer)
    errors[:params] << 'Discord webhook params token is invalid' if !params['token'].present? || !params['token'].is_a?(String)
  end
end
