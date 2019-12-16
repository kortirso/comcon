# Represents form object for DeliveryParam model
class DeliveryParamForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :params, Hash
  attribute :delivery, Delivery

  validates :params, :delivery, presence: true
  validate :params_for_delivery_type
  validate :exists?

  attr_reader :delivery_param

  def persist?
    return false unless valid?
    @delivery_param = id ? DeliveryParam.find_by(id: id) : DeliveryParam.new
    return false if @delivery_param.nil?
    @delivery_param.attributes = attributes.except(:id)
    @delivery_param.save
    true
  end

  private

  def exists?
    delivery_params = id.nil? ? DeliveryParam.all : DeliveryParam.where.not(id: id)
    return unless delivery_params.where(delivery: delivery).exists?
    errors[:delivery_param] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.delivery_param.already_exist')
  end

  def params_for_delivery_type
    return if delivery.nil?
    case delivery.delivery_type
      when 'discord_webhook' then check_discord_webhook_params
      when 'discord_message' then check_discord_message_params
      else true
    end
  end

  def check_discord_webhook_params
    return errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.is_not_hash') unless params.is_a?(Hash)
    errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.webhook_id_invalid') if !params['id'].present? || !params['id'].is_a?(Integer)
    errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.webhook_token_invalid') if !params['token'].present? || !params['token'].is_a?(String)
  end

  def check_discord_message_params
    return errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.is_not_hash') unless params.is_a?(Hash)
    return errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.channel_id_not_exist') unless params.key?('channel_id')
    return if delivery.nil?
    return if delivery.notification.nil?
    if delivery.deliveriable_type == 'Guild' && params['channel_id'].empty?
      return if %w[guild_request_creation bank_request_creation].include?(delivery.notification.event)
      errors[:params] << I18n.t('activemodel.errors.models.delivery_param_form.attributes.params.channel_id_is_empty')
    end
  end
end
