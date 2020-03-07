class AddCreatedSubscribesForFutureEvents < ActiveRecord::Migration[5.2]
  def change
    Event.where('start_time > ?', DateTime.now).find_each do |event|
      next unless %w[Guild Static].include?(event.eventable_type)

      subscribes = []
      subscribed_character_ids = event.characters.pluck(:id).push(event.owner.id)
      event.eventable.characters.where.not(id: subscribed_character_ids).find_each do |character|
        subscribes << Subscribe.new(subscribeable: event, character: character, status: 'created')
      end
      Subscribe.import subscribes
    end
  end
end
