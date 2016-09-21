class SmsSender
  def send_sms(phone_number,sms_message)
    #AMQPQueue.enqueue(:sms_notification, phone: phone_number, message: sms_message)

    raise "TWILIO_NUMBER not set" if ENV['TWILIO_NUMBER'].blank?
    twilio_client.account.sms.messages.create(
      from: ENV["TWILIO_NUMBER"],
      to:   Phonelib.parse(phone_number).international,
      body:  sms_message
    )

    if sms_message.length>75
      Rails.logger.warn ">>>>>>>>短信大于75个字符，需要优化>>>>>>>"
    end

  end

  def twilio_client
    Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"], ssl_verify_peer: false
  end

end
