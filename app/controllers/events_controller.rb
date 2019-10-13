class EventsController < ApplicationController
  before_action :find_events, only: %i[index], if: :json_request?
  before_action :find_selectors, only: %i[new]

  def index
    respond_to do |format|
      format.html {}
      format.json { render json: @events }
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
