# base mailer
class ApplicationMailer < ActionMailer::Base
  default from: 'support@guild-hall.org'
  layout 'mailer'
end
