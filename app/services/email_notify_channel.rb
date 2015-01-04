class EmailNotifyChannel < NotifyChannelBase

  def notifyable?
    member.email_activated
  end

  def notify!
    "#{klass}Mailer".constantize.send(notification_type, member.id).deliver
  end
end

