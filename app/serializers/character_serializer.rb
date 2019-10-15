class CharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class, :race, :guild, :subscribe_for_event, :main_role, :user_id

  def character_class
    object.character_class.name
  end

  def race
    object.race.name
  end

  def guild
    object.guild&.name
  end

  def subscribe_for_event
    subscribe = object.subscribes.find_by(event_id: @instance_options[:event_id])
    return nil if subscribe.nil?
    SubscribeSerializer.new(subscribe)
  end

  def main_role
    object.main_roles&.first&.name
  end
end
