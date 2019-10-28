class GuildsController < ApplicationController
  before_action :find_guild, only: %i[show]

  def index; end

  def show; end

  private

  def find_guild
    @guild = Guild.find_by(slug: params[:id])
    render_error('Object is not found') if @guild.nil?
  end
end
