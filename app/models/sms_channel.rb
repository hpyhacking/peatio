class SmsChannel < NotificationChannel

  def notify!(name, payload = { content: '' })
    if %w[withdraw_done deposit_accepted].include?(name)
      AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: payload[:content])
    end
  end

  def notifyable?
    member.phone_number_activated
  end

end
