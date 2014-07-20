class TicketMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  default from: ENV['SYSTEM_MAIL_FROM']


  def admin_notification(emails, ticket)
    @ticket_url = admin_ticket_url(ticket)
    @author_email = ticket.author.email

    mail to: emails, subject: I18n.t('private.tickets.admin_notification_title', email: @author_email)
  end
end
