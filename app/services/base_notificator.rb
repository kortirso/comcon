# Base notificator class
class BaseNotificator
  attr_reader :notification, :deliveriable_type

  def initialize(event_name:)
    @notification = Notification.find_by(event: event_name)
  end

  private

  def notify(event:, receiver_id:)
    deliveries = Delivery.where(deliveriable_id: receiver_id, deliveriable_type: deliveriable_type, notification_id: notification&.id)
    return if deliveries.empty?
    deliveries.each { |delivery| perform_delivery(delivery: delivery, event: event) }
  end

  def perform_delivery(delivery:, event:)
    content = define_content(event: event)
    case delivery.delivery_type
      when 'discord_webhook' then DiscordMethod::ExecuteWebhook.call(delivery_param: delivery.delivery_param, content: content)
      when 'discord_message' then DiscordMethod::CreateChannelMessage.call(delivery_param: delivery.delivery_param, content: content)
    end
  end

  def render_start_time(event:)
    start_time = event.start_time
    start_time_hours = start_time.strftime('%H').to_i + 3
    days = 0
    if start_time_hours < 10
      start_time_hours = "0#{start_time_hours}"
    elsif start_time_hours > 23
      start_time_hours = "0#{start_time_hours - 24}"
      days = ' (+1)'
    end
    "#{start_time.strftime('%-d.%-m.%Y')} #{start_time_hours}:#{start_time.strftime('%M')}#{days if days != 0}"
  end
end
