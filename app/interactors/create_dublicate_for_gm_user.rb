# frozen_string_literal: true

# Create delivery dublicate for gm user
class CreateDublicateForGmUser
  include Interactor

  # required context
  # context.delivery
  # context.delivery_param
  def call
    delivery = context.delivery
    return unless %w[guild_request_creation bank_request_creation].include?(delivery.notification.event)
    return if delivery.notification.status != 'guild'
    notification = Notification.find_by(event: delivery.notification.event, status: 1)
    return if notification.nil?
    user_ids.each do |user_id|
      next if Delivery.where(deliveriable_id: user_id, deliveriable_type: 'User', notification: notification).exists?
      delivery_params = { 'delivery_type' => 2, 'deliveriable_id' => user_id, 'deliveriable_type' => 'User', 'notification' => notification }
      delivery_param_params = { 'params' => { 'channel_id' => '' } }
      CreateDeliveryWithParams.call(delivery_params: delivery_params, delivery_param_params: delivery_param_params)
    end
  end

  private

  def user_ids
    case context.delivery.notification.event
    when 'guild_request_creation' then context.delivery.deliveriable.head_users.pluck(:id)
    when 'bank_request_creation' then context.delivery.deliveriable.bank_users.pluck(:id)
    else []
    end
  end
end
