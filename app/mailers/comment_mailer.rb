class CommentMailer < BaseMailer

  def user_notification(comment_id)
    comment = Comment.find comment_id
    @ticket_url = ticket_url(comment.ticket)

    mail to: comment.ticket.author.email
  end

  def admin_notification(comment_id)
    comment = Comment.find comment_id
    @ticket_url = admin_ticket_url(comment.ticket)
    @author_email = comment.author.email

    mail to: ENV['SUPPORT_MAIL']
  end

end
