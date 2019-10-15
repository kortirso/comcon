class EventsController < ApplicationController
  before_action :find_events, only: %i[index], if: :json_request?
  before_action :find_event, only: %i[show]
  before_action :find_selectors, only: %i[new]

  def index
    respond_to do |format|
      format.html {}
      format.json { render json: @events }
    end
  end

  def show
    respond_to do |format|
      format.html {}
      format.json do
        current_characters = Current.user.characters
        user_signed = Subscribe.where(event_id: @event.id, character_id: current_characters.pluck(:id)).exists?
        render json: {
          user_characters: user_signed ? [] : ActiveModelSerializers::SerializableResource.new(current_characters.includes(:race, :guild, :character_class, :subscribes, :main_roles).where('races.fraction_id = ?', @event.fraction.id).references(:race), each_serializer: CharacterSerializer, event_id: @event.id),
          characters: ActiveModelSerializers::SerializableResource.new(@event.characters.includes(:race, :guild, :character_class, :subscribes, :main_roles), each_serializer: CharacterSerializer, event_id: @event.id)
        }
      end
    end
  end

  def new; end

  def create
    event = EventForm.new(event_params)
    if event.persist?
      redirect_to root_path
    else
      find_selectors
      render :new
    end
  end

  private

  def find_events
    @events = Event.all
  end

  def find_event
    @event = Event.find_by(slug: params[:id])
    render_not_found('Object is not found') if @event.nil?
  end

  def find_selectors
    @characters = Character.where(user: Current.user).map { |elem| [elem.name, elem.id] }
    @dungeon_names = Dungeon.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
  end

  def event_params
    h = params.require(:event).permit(:name, :eventable_type).to_h
    h[:start_time] = ApplicationHelper.datetime_represent(params[:event], 'start_time')
    h[:owner] = Character.where(user: Current.user).find_by(id: params[:event][:owner_id])
    h[:dungeon] = Dungeon.find_by(id: params[:event][:dungeon_id])
    h
  end
end
