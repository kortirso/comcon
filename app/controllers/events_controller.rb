class EventsController < ApplicationController
  before_action :find_user_character_ids, only: %i[index]
  before_action :find_event_by_slug, only: %i[show]
  before_action :find_event, only: %i[edit]

  def index; end

  def show
    authorize! @event
  end

  def new; end

  def edit; end

  private

  def find_user_character_ids
    @user_character_ids = Current.user.characters.pluck(:id)
  end

  def find_event_by_slug
    @event = Event.find_by(slug: params[:id])
    render_error('Object is not found') if @event.nil?
  end

  def find_event
    @event = Event.find_by(id: params[:id])
    render_error('Object is not found') if @event.nil?
  end
end
