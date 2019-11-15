# Delete StaticInvite
class DeleteStaticInvite
  include Interactor

  # required context
  # context.static_invite
  def call
    context.static_invite.destroy
  end
end
