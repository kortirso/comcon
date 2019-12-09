class StaticInvitesController < ApplicationController
  before_action :find_character, only: %i[new]
  before_action :find_static_invite, only: %i[approve decline]

  def new; end

  def approve
    ApproveStaticInvite.call(static_invite: @static_invite, static: @static_invite.static, character: @static_invite.character, status: 2)
    redirect_to statics_path
  end

  def decline
    UpdateStaticInvite.call(static_invite: @static_invite, status: 1)
    redirect_to statics_path
  end

  private

  def find_character
    @character = Character.where(user_id: Current.user.id).find_by(id: params[:character_id])
    render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
  end

  def find_static_invite
    @static_invite = Current.user.static_invites.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @static_invite.nil?
  end
end
