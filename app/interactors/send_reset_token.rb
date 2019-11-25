# Send reset token to user's email
class SendResetToken
  include Interactor

  def call
    ResetPasswordEmailJob.perform_later(user_id: context.user.id)
  end
end
