# Send reset token to user's email
class SendResetToken
  include Interactor

  def call
    ResetPasswordEmailJob.perform_later(context.user.id)
  end
end
