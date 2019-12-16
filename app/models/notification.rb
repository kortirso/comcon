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

  def content(event_object:)
    case event
      when 'guild_event_creation' then guild_event_creation_content(event: event_object)
      when 'event_start_soon' then event_start_soon_content(event: event_object)
      when 'guild_static_event_creation' then guild_static_event_creation_content(event: event_object)
      when 'guild_request_creation' then guild_request_creation_content(guild_invite: event_object)
      when 'bank_request_creation' then bank_request_creation_content(bank_request: event_object)
    end
  end

  private

  def guild_event_creation_content(event:)
    content = "Создано событие для гильдии - \"#{event.name}\" от #{event.owner.full_name}, "
    content += "место проведения - #{event.dungeon.name['ru']}, " unless event.dungeon_id.nil?
    content + "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
  end

  def event_start_soon_content(event:)
    content = "Скоро начнется событие \"#{event.name}\" от #{event.owner.full_name}, "
    content += "место проведения - #{event.dungeon.name['ru']}, " unless event.dungeon_id.nil?
    content + "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
  end

  def guild_static_event_creation_content(event:)
    content = "Создано событие для статика \"#{event.eventable.name}\" - \"#{event.name}\" от #{event.owner.full_name}, "
    content += "место проведения - #{event.dungeon.name['ru']}, " unless event.dungeon_id.nil?
    content + "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
  end

  def guild_request_creation_content(guild_invite:)
    "Создан запрос на вступление в гильдию \"#{guild_invite.guild.full_name}\" от #{guild_invite.character.name}, для просмотра запросов посетите портал гильдии по адресу https://guild-hall.org/ru/guilds/#{guild_invite.guild.slug}/management"
  end

  def bank_request_creation_content(bank_request:)
    "Создан банковский запрос в гильдии \"#{bank_request.bank.guild.full_name}\" от #{bank_request.character_name}, для просмотра запроса посетите портал гильдии по адресу https://guild-hall.org/ru/guilds/#{bank_request.bank.guild.slug}/bank"
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
