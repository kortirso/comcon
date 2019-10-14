class SubscribesController < ApplicationController
  before_action :find_subscribe, only: %i[approve]

  def create
    create_subscribe(subscribe_params)
  end

  def reject
    create_subscribe(subscribe_params.merge(status: 'rejected'))
  end

  def approve
    authorize! @subscribe
    create_subscribe(@subscribe.attributes.merge(subscribe_params.merge(status: 'approved')))
  end

  private

  def find_subscribe
    @subscribe = Subscribe.find_by(character_id: params[:subscribe][:character_id], event_id: params[:subscribe][:event_id])
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
    user_signed = Subscribe.where(event_id: event.id, character_id: Character.where(user: Current.user).pluck(:id)).first
    render json: {
      user_characters: user_signed ? [] : ActiveModelSerializers::SerializableResource.new(Character.where(user: Current.user).includes(:race, :guild, :character_class, :subscribes).where('races.fraction_id = ?', event.fraction.id).references(:race), each_serializer: CharacterSerializer, event_id: event.id),
      characters: ActiveModelSerializers::SerializableResource.new(event.characters.includes(:race, :guild, :character_class, :subscribes), each_serializer: CharacterSerializer, event_id: event.id)
    }
  end

  def subscribe_params
    h = {}
    h[:event] = Event.find_by(id: params[:subscribe][:event_id])
    h[:character] = Character.where(user: Current.user).find_by(id: params[:subscribe][:character_id])
    h
  end
end
