class ActivitiesController < ApplicationController
  before_action :find_activities, only: %i[index]
  before_action :find_close_events, only: %i[index]
  before_action :find_guild, only: %i[new]
  before_action :find_activity, only: %i[edit destroy]

  def index; end

  def new
    authorize! @guild, with: GuildPolicy, to: :management?
  end

  def edit
    authorize! @activity.guild, with: GuildPolicy, to: :management?
  end

  def destroy
    authorize! @activity.guild, with: GuildPolicy, to: :management?
    @activity.destroy
    redirect_to activities_guild_path(@activity.guild.slug), status: 303
  end

  private

  def find_activities
    @activities = Activity.where(guild_id: Current.user.guilds.ids).order(id: :desc).includes(guild: :world).first(10)
  end

  def find_close_events
    @subscribes = Subscribe.where(subscribeable_type: 'Event', character_id: Current.user.characters.ids).includes(:event, :character).where('events.start_time > ?', DateTime.now).order(start_time: :asc).references(:event)
  end

  def find_guild
    @guild = Guild.find_by(id: params[:guild_id])
    render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
  end

  def find_activity
    @activity = Activity.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @activity.nil?
  end
end
