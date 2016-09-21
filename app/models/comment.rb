class Comment < ActiveRecord::Base
  after_commit :send_notification, on: [:create]

  acts_as_readable on: :created_at
  belongs_to :ticket
  belongs_to :author, class_name: 'Member', foreign_key: 'author_id'

  validates :content, presence: true

  private

  def send_notification
    ticket_author = self.ticket.author

    if ticket_author != self.author
      AMQPQueue.enqueue(:business_notification,message_class: "CommentMessage",business_id: self.id,mailer_class:"CommentMailer",method_name: "user_notification")
      #CommentMailer.user_notification(self.id).deliver
    else
      AMQPQueue.enqueue(:business_notification,message_class: "CommentMessage",business_id: self.id,mailer_class:"CommentMailer",method_name: "admin_notification")
      #CommentMailer.admin_notification(self.id).deliver
    end
  end
end
