# frozen_string_literal: true

# Validate email of new user
class ValidateUserEmail
  include Interactor

  # required context
  # context.user
  # context.confirmation_token
  def call
    context.fail!(message: "Confirmation token can't be blank") if context.confirmation_token.blank?
    context.fail!(message: 'Confirmation token is invalid') if context.confirmation_token != context.user.confirmation_token
    context.user.update(confirmed_at: DateTime.now, confirmation_token: nil)
  end
end
