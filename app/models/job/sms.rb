module Job
  class Sms

    @queue = :sms

    class << self
      def perform(sms_token_id)
        token = SmsToken.find sms_token_id

        twilio_client.account.sms.messages.create(
          from: ENV["TWILIO_NUMBER"],
          to:   token.member.phone_number,
          body: token.sms_message
        )
      end

      def twilio_client
        Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
      end
    end

  end
end
