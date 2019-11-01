class StaticsController < ApplicationController
  before_action :find_guild, only: %i[new]

  def index; end

  def new
    authorize! @guild, with: StaticPolicy if @guild.present?
  end

  private

  def find_guild
    return unless params[:guild_id].present?
    @guild = Guild.find_by(id: params[:guild_id])
    render_error('Object is not found') if @guild.nil?
  end
end
