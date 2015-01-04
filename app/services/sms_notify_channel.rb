class SmsNotifyChannel < NotifyChannelBase
  def notifyable
    member.phone_number_activated
  end

  def notify!
    AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: payload[:content])
  end
end
