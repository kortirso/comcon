# defines rendering response for Events and Subscribes controller
module EventPresentable
  extend ActiveSupport::Concern

  private

  def render_event_characters(event)
    current_characters = Current.user.characters
    user_signed = Subscribe.where(event_id: event.id, character_id: current_characters.pluck(:id)).exists?
    render json: {
      user_characters: user_signed ? [] : ActiveModelSerializers::SerializableResource.new(current_characters.includes(:race, :guild, :character_class, :subscribes, :main_roles).where('races.fraction_id = ?', event.fraction.id).references(:race), each_serializer: CharacterSerializer, event_id: event.id).as_json[:characters],
      characters: ActiveModelSerializers::SerializableResource.new(event.characters.includes(:race, :guild, :character_class, :subscribes, :main_roles), each_serializer: CharacterSerializer, event_id: event.id).as_json[:characters]
    }
  end
end
