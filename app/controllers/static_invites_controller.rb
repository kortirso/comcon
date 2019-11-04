class StaticInvitesController < ApplicationController
  before_action :find_static_invite

  def approve
    ApproveStaticInvite.call(static_invite: @static_invite, static: @static_invite.static, character: @static_invite.character, status: 2)
    redirect_to statics_path
  end

  def decline
    UpdateStaticInvite.call(static_invite: @static_invite, status: 1)
    redirect_to statics_path
  end

  private

  def find_static_invite
    @static_invite = Current.user.static_invites.find_by(id: params[:id])
    render_error('Object is not found') if @static_invite.nil?
  end
end
