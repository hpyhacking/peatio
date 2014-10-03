class BaseMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  layout 'mailers/application'

  default from: ENV['SYSTEM_MAIL_FROM']
end
