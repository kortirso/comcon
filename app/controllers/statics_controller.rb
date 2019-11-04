class StaticsController < ApplicationController
  before_action :find_user_statics, only: %i[index]
  before_action :find_guild, only: %i[new]
  before_action :find_static_by_slug, only: %i[show edit destroy management]

  def index; end

  def show; end

  def new
    authorize! @guild, with: StaticPolicy if @guild.present?
  end

  def edit
    authorize! @static
  end

  def destroy
    authorize! @static
    @static.destroy
    redirect_to @static.staticable_type == 'Guild' ? management_guild_path(@static.staticable.slug) : statics_path
  end

  def management
    authorize! @static
  end

  private

  def find_user_statics
    @user_statics = Current.user.statics
    @user_static_invites = Current.user.static_invites
  end

  def find_guild
    return unless params[:guild_id].present?
    @guild = Guild.find_by(id: params[:guild_id])
    render_error('Object is not found') if @guild.nil?
  end

  def find_static_by_slug
    @static = Static.find_by(slug: params[:id])
    render_error('Object is not found') if @static.nil?
  end
end
