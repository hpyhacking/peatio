module Job
  class Sms

    @queue = :sms

    class << self
      def perform(phone_number, sms_message)
        twilio_client.account.sms.messages.create(
          from: ENV["TWILIO_NUMBER"],
          to:   phone_number,
          body: sms_message
        )
      end

      def twilio_client
        Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
      end
    end

  end
end
