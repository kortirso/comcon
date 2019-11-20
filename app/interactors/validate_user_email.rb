# Validate email of new user
class ValidateUserEmail
  include Interactor

  # required context
  # context.user
  # context.confirmation_token
  def call
    puts context.inspect
    context.fail!(message: 'Confirmation token is invalid') if context.confirmation_token != context.user.confirmation_token
    context.user.update(confirmed_at: DateTime.now)
  end
end
