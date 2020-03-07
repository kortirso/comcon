# frozen_string_literal: true

# Send reset password token for user
class ResetPasswordEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    UserMailer.reset_password_email(user_id: user_id).deliver_now
  end
end
