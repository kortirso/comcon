class ActivitiesController < ApplicationController
  before_action :find_activities, only: %i[index]
  before_action :find_guild, only: %i[new]

  def index; end

  def new
    authorize! @guild, with: GuildPolicy, to: :management?
  end

  private

  def find_activities
    @activities = Activity.where(guild_id: Current.user.guilds.ids).order(id: :desc).includes(guild: :world).first(10)
  end

  def find_guild
    @guild = Guild.find_by(id: params[:guild_id])
    render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
  end
end
