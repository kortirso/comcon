class EventsController < ApplicationController
  before_action :find_user_character_ids, only: %i[index]
  before_action :find_event, only: %i[show]

  def index; end

  def show
    authorize! @event
  end

  def new; end

  private

  def find_user_character_ids
    @user_character_ids = Current.user.characters.pluck(:id)
  end

  def find_event
    @event = Event.find_by(slug: params[:id])
    render_error('Object is not found') if @event.nil?
  end
end
