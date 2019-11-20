module Notificators
  # Notify about new event
  class CreateEventNotificator < BaseNotificator
    def self.call(event_id:)
      new.call(event_id: event_id)
    rescue
      { error: 'Rescued' }
    end

    def initialize
      @deliveriable_type = 'Guild'
      super(event_name: 'guild_event_creation')
    end

    def call(event_id:)
      event = Event.find_by(id: event_id)
      return if event.nil?
      case event.eventable_type
        when 'Guild' then notify(event: event, receiver_id: event.eventable_id)
      end
    end

    private

    def define_content(event:)
      content = []
      content.push "Создано событие для гильдии - \"#{event.name}\" от #{event.owner.full_name}"
      content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
      content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
      content.join(', ')
    end
  end
end
