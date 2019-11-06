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

  def define_content(event, content = [])
    start_time = event.start_time
    content.push "Создано событие для гильдии - \"#{event.name}\" от #{event.owner.full_name}"
    content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
    content.push "время начала (по мск) - #{start_time.strftime('%-d.%-m.%Y')} #{start_time.strftime('%H').to_i + 3}:#{start_time.strftime('%M')}, для ознакомления с событием посетите портал гильдии по адресу http://206.81.30.158:3001/ru/events/#{event.slug}"
    content.join(', ')
  end
end
