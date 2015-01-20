class SmsChannel < NotificationChannel
  SUPORT_NOTIFY_TYPE = %w[withdraw_done deposit_accepted]

  def notify!(payload = { content: '' })
    @name = self.notify_type
    @payload = payload
    if SUPORT_NOTIFY_TYPE.include?(name) && notifyable?
      AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: payload[:content])
    end
  end

  def notifyable?
    member.phone_number_activated
  end

end
