class SubscribesController < ApplicationController
  before_action :find_subscribe, only: %i[update]

  def create
    create_subscribe(subscribe_params)
  end

  def update
    authorize! @subscribe
    create_subscribe(@subscribe.attributes.merge(subscribe_params.merge(character: @subscribe.character, event: @subscribe.event)))
  end

  private

  def find_subscribe
    @subscribe = Subscribe.find_by(id: params[:id])
  end

  def create_subscribe(options)
    subscribe_form = SubscribeForm.new(options)
    if subscribe_form.persist?
      render_event_characters(subscribe_form.event)
    else
      render json: { result: 'Failed' }
    end
  end

  def render_event_characters(event)
    current_characters = Current.user.characters
    user_signed = Subscribe.where(event_id: event.id, character_id: current_characters.pluck(:id)).exists?
    render json: {
      user_characters: user_signed ? [] : ActiveModelSerializers::SerializableResource.new(current_characters.includes(:race, :guild, :character_class, :subscribes, :main_roles).where('races.fraction_id = ?', event.fraction.id).references(:race), each_serializer: CharacterSerializer, event_id: event.id),
      characters: ActiveModelSerializers::SerializableResource.new(event.characters.includes(:race, :guild, :character_class, :subscribes, :main_roles), each_serializer: CharacterSerializer, event_id: event.id)
    }
  end

  def subscribe_params
    h = update_subscribe_params.to_h
    h[:event] = Event.find_by(id: params[:subscribe][:event_id])
    h[:character] = Character.where(user: Current.user).find_by(id: params[:subscribe][:character_id])
    h
  end

  def update_subscribe_params
    params.require(:subscribe).permit(:status)
  end
end
