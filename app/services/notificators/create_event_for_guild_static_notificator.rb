module Notificators
  # Notify about new event
  class CreateEventForGuildStaticNotificator < BaseNotificator
    def self.call(event_id:)
      new.call(event_id: event_id)
    rescue
      { error: 'Rescued' }
    end

    def initialize
      @deliveriable_type = 'Guild'
      super(event_name: 'event_creation_for_guild_static')
    end

    def call(event_id:)
      event = Event.find_by(id: event_id)
      return if event.nil?
      notify(event: event, receiver_id: event.eventable&.staticable_id)
    end

    private

    def define_content(event:)
      content = []
      content.push "Создано событие для статика \"#{event.eventable.name}\" - \"#{event.name}\" от #{event.owner.full_name}"
      content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
      content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
      content.join(', ')
    end
  end
end
