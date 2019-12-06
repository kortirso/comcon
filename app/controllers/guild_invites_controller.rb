class GuildInvitesController < ApplicationController
  before_action :find_character, only: %i[new]

  def new; end

  private

  def find_character
    @character = Character.where(user_id: Current.user.id, guild_id: nil).find_by(id: params[:character_id])
    render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
  end
end
