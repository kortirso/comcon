# Represents notifications about events
class Notification < ApplicationRecord
  enum status: { guild: 0, user: 1 }, _prefix: :status

  has_many :deliveries, dependent: :destroy

  def self.cache_key(notifications)
    {
      serializer: 'notifications',
      stat_record: notifications.maximum(:updated_at)
    }
  end

  def content(event:)
    case event.name
      when 'guild_event_creation' then guild_event_creation_content(event: event)
      when 'event_start_soon' then event_start_soon_content(event: event)
      when 'guild_static_event_creation' then guild_static_event_creation_content(event: event)
    end
  end

  private

  def guild_event_creation_content(event:)
    content = []
    content.push "Создано событие для гильдии - \"#{event.name}\" от #{event.owner.full_name}"
    content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
    content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
    content.join(', ')
  end

  def event_start_soon_content(event:)
    content = []
    content.push "Скоро начнется событие \"#{event.name}\" от #{event.owner.full_name}"
    content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
    content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
    content.join(', ')
  end

  def guild_static_event_creation_content(event:)
    content = []
    content.push "Создано событие для статика \"#{event.eventable.name}\" - \"#{event.name}\" от #{event.owner.full_name}"
    content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
    content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
    content.join(', ')
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
