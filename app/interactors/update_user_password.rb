# frozen_string_literal: true

# Update password for user
class UpdateUserPassword
  include Interactor

  # required context
  # context.user
  # context.user_password_params
  def call
    validate_equality
    user = context.user
    return if user.update(password: context.user_password_params[:password])
    context.fail!(message: user.errors.full_messages)
  end

  private

  def validate_equality
    return if context.user_password_params[:password] == context.user_password_params[:password_confirmation]
    context.fail!(message: I18n.t('custom_errors.passwords_different'))
  end
end
