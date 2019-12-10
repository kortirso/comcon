class StaticInvitesController < ApplicationController
  before_action :find_characters, only: %i[find]
  before_action :find_static_invite, only: %i[approve decline]

  def find; end

  def approve
    ApproveStaticInvite.call(static_invite: @static_invite, static: @static_invite.static, character: @static_invite.character, status: 2)
    redirect_to statics_path
  end

  def decline
    UpdateStaticInvite.call(static_invite: @static_invite, status: 1)
    redirect_to statics_path
  end

  private

  def find_characters
    @user_characters = ActiveModelSerializers::SerializableResource.new(Character.where(user: Current.user).includes(race: :fraction), each_serializer: CharacterIndexSerializer).as_json[:characters]
  end

  def find_static_invite
    @static_invite = Current.user.static_invites.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @static_invite.nil?
  end
end
