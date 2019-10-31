class EventsController < ApplicationController
  before_action :find_event, only: %i[show]

  def index; end

  def show
    authorize! @event
  end

  def new; end

  private

  def find_event
    @event = Event.find_by(slug: params[:id])
    render_error('Object is not found') if @event.nil?
  end
end
