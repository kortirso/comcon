class EventsController < ApplicationController
  include EventPresentable

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
      format.json { render_event_characters(@event) }
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

  def filter_values
    render json: {
      worlds: ActiveModelSerializers::SerializableResource.new(World.all, each_serializer: WorldSerializer),
      fractions: ActiveModelSerializers::SerializableResource.new(Fraction.all, each_serializer: FractionSerializer),
      characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer),
      guilds: ActiveModelSerializers::SerializableResource.new(Current.user.guilds.includes(:fraction, :world), each_serializer: GuildSerializer)
    }
  end

  private

  def find_events
    @events = Event.all
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
    h = params.require(:event).permit(:name, :eventable_type).to_h
    h[:start_time] = ApplicationHelper.datetime_represent(params[:event], 'start_time')
    h[:owner] = Character.where(user: Current.user).find_by(id: params[:event][:owner_id])
    h[:dungeon] = Dungeon.find_by(id: params[:event][:dungeon_id])
    h
  end
end
