module Notificators
  # Notificate about coming soon events
  class ComingSoonEventsNotificator < BaseNotificator
    def self.call
      new.call
    rescue
      { error: 'Rescued' }
    end

    def initialize
      @deliveriable_type = 'User'
      super(event_name: 'event_start_soon')
    end

    def call
      current_time = DateTime.now.utc + 30.minutes
      Event.where('start_time > ? AND start_time <= ?', current_time, current_time + 10.minutes).each do |event|
        notify_users(event: event)
      end
    end

    private

    def notify_users(event:)
      event.signed_users.with_discord_identity.each { |user| notify(event: event, receiver_id: user.id) }
    end

    def define_content(event:)
      content = []
      content.push "Скоро начнется событие \"#{event.name}\" от #{event.owner.full_name}"
      content.push "место проведения - #{event.dungeon.name['ru']}" unless event.dungeon_id.nil?
      content.push "время начала (по мск) - #{render_start_time(event: event)}, для ознакомления с событием посетите портал гильдии по адресу https://guild-hall.org/ru/events/#{event.slug}"
      content.join(', ')
    end
  end
end
