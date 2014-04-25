module Worker
  class SmsNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      twilio_client.account.sms.messages.create(
        from: ENV["TWILIO_NUMBER"],
        to:   payload[:phone],
        body: payload[:message]
      )
    end

    def twilio_client
      Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    end

  end
end
