class AddHiddenSubscribesForExistedEvents < ActiveRecord::Migration[5.2]
  def change
    Event.where('start_time > ?', DateTime.now).where(eventable_type: 'Static').find_each do |event|
      next unless event.eventable.staticable_type == 'Guild'

      subscribes = []
      subscribed_character_ids = event.characters.pluck(:id)
      event.eventable.staticable.characters_with_leader_role.where.not(id: subscribed_character_ids).find_each do |character|
        subscribes << Subscribe.new(subscribeable: event, character: character, status: 'hidden')
      end
      Subscribe.import subscribes
    end
  end
end
