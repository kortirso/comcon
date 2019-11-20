# Send email for mail confirmation
class ConfirmUserEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    UserMailer.confirmation_email(user_id: user_id).deliver_now
  end
end
