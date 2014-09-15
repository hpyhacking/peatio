class CommentMailer < BaseMailer

  def user_notification(email, comment)
    @ticket_url = ticket_url(comment.ticket)
    mail to: email, subject: I18n.t('private.tickets.comments.user_notification_title')
  end

  def admin_notification(emails, comment)
    @ticket_url = admin_ticket_url(comment.ticket)
    @author_email = comment.author.email
    mail to: emails, subject: I18n.t('private.tickets.comments.admin_notification_title', email: @author_email)
  end

end
