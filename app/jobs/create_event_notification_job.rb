# Send notifications about creating events
class CreateEventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id:)
    event = Event.find_by(id: event_id)
    return if event.nil?
    case event.eventable_type
      when 'Guild' then guild_notification(event)
    end
  end

  private

  def guild_notification(event)
    notification = Notification.find_by(event: 'guild_event_creation')
    return if notification.nil?
    deliveries = Delivery.where(deliveriable_id: event.eventable_id, deliveriable_type: 'Guild', notification_id: notification.id)
    return if deliveries.empty?
    deliveries.each do |delivery|
      perform_delivery(delivery, event)
    end
  end

  def perform_delivery(delivery, event)
    content = define_content(event)
    case delivery.delivery_type
      when 'discord_webhook' then DeliveryMethod::DiscordWebhook.call(delivery_param: delivery.delivery_param, content: content)
    end
  end

  def define_content(event)
    content = "Создано событие для гильдии, название - #{event.name}, время начала (GTM +0) - #{event.start_time.strftime('%H:%M %-d.%-m.%Y')}"
    content += ", подземелье - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
    content + ', пожалуй стоит отметиться ради ЕПГП'
  end
end
