class BaseMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  add_template_helper MailerHelper

  layout 'mailers/application'

  default from: ENV['SYSTEM_MAIL_FROM']
end
