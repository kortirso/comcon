# Create what need to add after adding GM role from character
class CheckAddedHeadRole
  include Interactor

  # required context
  # context.guild_role
  def call
    return if context.guild_role.name != 'gm'
    user = context.guild_role.character.user
    guild_notification = Notification.find_by(event: 'guild_request_creation', status: 0)
    return if guild_notification.nil?
    return unless Delivery.where(deliveriable: context.guild_role.guild, notification: guild_notification).exists?
    user_notification = Notification.find_by(event: 'guild_request_creation', status: 1)
    return if user_notification.nil?
    return if Delivery.where(deliveriable: user, notification: user_notification).exists?
    delivery_params = { 'delivery_type' => 2, 'deliveriable_id' => user.id, 'deliveriable_type' => 'User', 'notification' => user_notification }
    delivery_param_params = { 'params' => { 'channel_id' => '' } }
    CreateDeliveryWithParams.call(delivery_params: delivery_params, delivery_param_params: delivery_param_params)
  end
end
