# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :find_user_character_ids, only: %i[index]
  before_action :find_event_by_slug, only: %i[show edit]

  def index; end

  def show
    authorize! @event
  end

  def new; end

  def edit
    authorize! @event
  end

  private

  def find_user_character_ids
    @user_character_ids = Current.user.characters.pluck(:id)
  end

  def find_event_by_slug
    @event = Event.find_by(slug: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @event.nil?
  end
end
