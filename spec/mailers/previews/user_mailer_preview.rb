# Preview all emails at http://localhost:5000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def confirmation_email_preview
    UserMailer.confirmation_email(user_id: User.last.id)
  end
end
