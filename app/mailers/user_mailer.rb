# frozen_string_literal: true

# Emails for users
class UserMailer < ApplicationMailer
  def confirmation_email(user_id:)
    @user = User.find_by(id: user_id)
    return if @user.nil?

    mail(to: @user.email, subject: t('mailer.user.confirmation_email.subject'))
  end

  def reset_password_email(user_id:)
    @user = User.find_by(id: user_id)
    return if @user.nil?

    mail(to: @user.email, subject: t('mailer.user.reset_password_email.subject'))
  end
end
