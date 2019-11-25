# Update reset token for user
class CreateResetToken
  include Interactor

  def call
    context.user.update(reset_password_token: SecureRandom.urlsafe_base64.to_s, reset_password_token: DateTime.now)
  end

  def rollback
    context.user.update(reset_password_token: nil, reset_password_token: nil)
  end
end
