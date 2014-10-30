module Worker
  class SmsNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      raise "TWILIO_NUMBER not set" if ENV['TWILIO_NUMBER'].blank?

      twilio_client.account.sms.messages.create(
        from: ENV["TWILIO_NUMBER"],
        to:   Phonelib.parse(payload[:phone]).international,
        body: payload[:message]
      )
    end

    def twilio_client
      Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"], ssl_verify_peer: false
    end

  end
end
