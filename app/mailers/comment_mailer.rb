class CommentMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  default from: ENV['SYSTEM_MAIL_FROM']

  def notify(email, comment)
    @ticket_url = ticket_url(comment.ticket)
    mail to: email, subject: I18n.t('private.tickets.notify_title')
  end

end
