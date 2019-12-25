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
      when 'activity_creation' then activity_creation_content(activity: event_object)
    end
  end

  private

  def guild_event_creation_content(event:)
    locale = event.eventable.locale
    I18n.locale = locale
    content = "#{I18n.t('notification.guild_event_creation_content.title')} - \"#{event.name}\" #{I18n.t('notification.from')} #{event.owner.full_name}, "
    content += "#{I18n.t('notification.place')} - #{event.dungeon.name[locale]}, " unless event.dungeon_id.nil?
    content + "#{I18n.t('notification.start_time')} - #{render_start_time(event: event)}, #{I18n.t('notification.visit')} https://guild-hall.org/#{locale_for_url(locale: locale)}events/#{event.slug}"
  end

  def event_start_soon_content(event:)
    locale = event.eventable.locale
    I18n.locale = locale
    content = "#{I18n.t('notification.event_start_soon_content.title')} \"#{event.name}\" #{I18n.t('notification.from')} #{event.owner.full_name}, "
    content += "#{I18n.t('notification.place')} - #{event.dungeon.name[locale]}, " unless event.dungeon_id.nil?
    content + "#{I18n.t('notification.start_time')} - #{render_start_time(event: event)}, #{I18n.t('notification.visit')} https://guild-hall.org/#{locale_for_url(locale: locale)}events/#{event.slug}"
  end

  def guild_static_event_creation_content(event:)
    locale = event.eventable.locale
    I18n.locale = locale
    content = "#{I18n.t('notification.guild_static_event_creation_content.title')} \"#{event.eventable.name}\" - \"#{event.name}\" #{I18n.t('notification.from')} #{event.owner.full_name}, "
    content += "#{I18n.t('notification.place')} - #{event.dungeon.name[locale]}, " unless event.dungeon_id.nil?
    content + "#{I18n.t('notification.start_time')} - #{render_start_time(event: event)}, #{I18n.t('notification.visit')} https://guild-hall.org/#{locale_for_url(locale: locale)}events/#{event.slug}"
  end

  def guild_request_creation_content(guild_invite:)
    locale = guild_invite.guild.locale
    I18n.locale = locale
    "#{I18n.t('notification.guild_request_creation_content.title')} \"#{guild_invite.guild.full_name}\" #{I18n.t('notification.from')} #{guild_invite.character.name}, #{I18n.t('notification.requests')} https://guild-hall.org/#{locale_for_url(locale: locale)}guilds/#{guild_invite.guild.slug}/management"
  end

  def bank_request_creation_content(bank_request:)
    locale = bank_request.bank.guild.locale
    I18n.locale = locale
    "#{I18n.t('notification.bank_request_creation_content.title')} \"#{bank_request.bank.guild.full_name}\" #{I18n.t('notification.from')} #{bank_request.character_name}, #{I18n.t('notification.requests')} https://guild-hall.org/#{locale_for_url(locale: locale)}guilds/#{bank_request.bank.guild.slug}/bank"
  end

  def activity_creation_content(activity:)
    "#{activity.title}. #{activity.description}. #{activity.guild.full_name}."
  end

  def locale_for_url(locale:)
    return "#{locale}/" if locale != 'en'
    ''
  end

  def render_start_time(event:)
    time_offset = event_time_offset(event: event)
    start_time = event.start_time
    start_time_hours = start_time.strftime('%H').to_i + time_offset
    days = 0
    if start_time_hours < 10
      start_time_hours = "0#{start_time_hours}"
    elsif start_time_hours > 23
      start_time_hours = "0#{start_time_hours - 24}"
      days = ' (+1)'
    end
    "#{start_time.strftime('%-d.%-m.%Y')} #{start_time_hours}:#{start_time.strftime('%M')}#{days if days != 0}  (GMT #{time_offset_value(time_offset)})"
  end

  def time_offset_value(time_offset)
    time_offset.positive? ? "+#{time_offset}" : time_offset
  end

  def event_time_offset(event:)
    case event.eventable_type
      when 'Guild' then (event.eventable.time_offset.value || 0)
      when 'Static' then event.eventable.time_offset_value
      else 0
    end
  end
end
