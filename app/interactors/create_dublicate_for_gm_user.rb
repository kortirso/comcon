# Create delivery dublicate for gm user
class CreateDublicateForGmUser
  include Interactor

  # required context
  # context.delivery
  # context.delivery_param
  def call
    return if context.delivery.notification.event != 'guild_request_creation' && context.delivery.notification.status == 'guild'
    notification = Notification.find_by(event: 'guild_request_creation', status: 1)
    return if notification.nil?
    user_ids = context.delivery.deliveriable.head_users.pluck(:id)
    user_ids.each do |user_id|
      delivery_params = { 'delivery_type' => 2, 'deliveriable_id' => user_id, 'deliveriable_type' => 'User', 'notification' => notification }
      delivery_param_params = { 'params' => { 'channel_id' => '' } }
      CreateDeliveryWithParams.call(delivery_params: delivery_params, delivery_param_params: delivery_param_params)
    end
  end
end
