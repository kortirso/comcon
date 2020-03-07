# frozen_string_literal: true

# Confirm User
class ConfirmUser
  include Interactor

  # required context
  # context.user
  def call
    return if context.user.confirmed?
    context.user.update(confirmed_at: DateTime.now)
  end
end
