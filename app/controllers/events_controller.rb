class EventsController < ApplicationController
  include EventPresentable

  before_action :find_start_of_month, only: %i[index], if: :json_request?
  before_action :find_events, only: %i[index], if: :json_request?
  before_action :find_event, only: %i[show]
  before_action :find_selectors, only: %i[new]

  def index
    respond_to do |format|
      format.html {}
      format.json do
        result = ActiveModelSerializers::SerializableResource.new(@events, root: 'events', each_serializer: EventSerializer).as_json
        render json: { events: result[:events] }
      end
    end
  end

  def show
    authorize! @event
    respond_to do |format|
      format.html {}
      format.json { render_event_characters(@event) }
    end
  end

  def new; end

  def create
    event_form = EventForm.new(event_params)
    if event_form.persist?
      CreateSubscribe.call(event: event_form.event, character: event_form.event.owner, status: 'signed')
      redirect_to events_path
    else
      find_selectors
      render :new
    end
  end

  def filter_values
    render json: {
      worlds: ActiveModelSerializers::SerializableResource.new(World.all, each_serializer: WorldSerializer).as_json[:worlds],
      fractions: ActiveModelSerializers::SerializableResource.new(Fraction.all, each_serializer: FractionSerializer).as_json[:fractions],
      characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
      guilds: ActiveModelSerializers::SerializableResource.new(Current.user.guilds.includes(:fraction, :world), each_serializer: GuildSerializer).as_json[:guilds]
    }
  end

  private

  def find_start_of_month
    @start_of_month = params[:year].present? && params[:month].present? ? DateTime.new(params[:year].to_i, params[:month].to_i, 1, 0, 0, 0) : DateTime.now.new_offset(0)
  end

  def find_events
    @events = Event.where('start_time >= ? AND start_time < ?', @start_of_month.beginning_of_month, @start_of_month.end_of_month)
    @events = @events.where(eventable_type: params[:eventable_type]) if params[:eventable_type].present?
    @events = @events.where(eventable_id: params[:eventable_id]) if params[:eventable_id].present?
    @events = @events.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
    if params[:character_id].present?
      character = Current.user.characters.find_by(id: params[:character_id])
      @events = character.present? ? @events.available_for_character(character) : @events.available_for_user(Current.user)
    else
      @events = @events.available_for_user(Current.user)
    end
  end

  def find_event
    @event = Event.find_by(slug: params[:id])
    render_error('Object is not found') if @event.nil?
  end

  def find_selectors
    @characters = Character.where(user: Current.user).map { |elem| [elem.name, elem.id] }
    @dungeon_names = Dungeon.all.map { |elem| [elem.name[I18n.locale.to_s], elem.id] }
  end

  def event_params
    h = params.require(:event).permit(:name, :eventable_type, :hours_before_close).to_h
    h[:start_time] = ApplicationHelper.datetime_represent(params[:event], 'start_time')
    h[:owner] = Current.user.characters.find_by(id: params[:event][:owner_id])
    h[:dungeon] = Dungeon.find_by(id: params[:event][:dungeon_id])
    h
  end
end
