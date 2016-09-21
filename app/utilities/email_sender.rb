class EmailSender
  def send_email(mailer_class,method_name,*args)
    #AMQPQueue.enqueue(:email_notification, mailer_class: mailer_class, method: method_name, args: args)

    mailer = mailer_class.constantize
    action = method_name
    args   = args
    message = mailer.send(:new, action, *args).message
    message.deliver

  end

end
