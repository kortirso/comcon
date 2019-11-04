# Update StaticInvite
class UpdateStaticInvite
  include Interactor

  # required context
  # context.static_invite
  # context.status
  def call
    static_invite = context.static_invite
    static_invite_form = StaticInviteForm.new(static_invite.attributes.merge(static: static_invite.static, character: static_invite.character, status: context.status))
    context.fail!(message: static_invite_form.errors.full_messages) unless static_invite_form.persist?
  end
end
