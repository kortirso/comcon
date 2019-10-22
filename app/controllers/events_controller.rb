class EventsController < ApplicationController
  before_action :find_event, only: %i[show]
  before_action :find_selectors, only: %i[new]

  def index; end

  def show
    authorize! @event
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

  private

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
