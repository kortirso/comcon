# frozen_string_literal: true

class ActivitiesController < ApplicationController
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
    redirect_to activities_guild_path(@activity.guild.slug), status: :see_other
  end

  private

  def find_guild
    @guild = Guild.find_by(id: params[:guild_id])
    render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
  end

  def find_activity
    @activity = Activity.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @activity.nil?
  end
end
