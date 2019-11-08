# Create Identity
class CreateIdentity
  include Interactor

  # required context
  # context.uid
  # context.provider
  # context.user
  # context.email
  def call
    identity_form = IdentityForm.new(uid: context.uid, provider: context.provider, user: context.user, email: context.email)
    if identity_form.persist?
      context.identity = identity_form.identity
    else
      context.fail!(message: identity_form.errors.full_messages)
    end
  end
end
