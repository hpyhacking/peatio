module Job
  class Sms

    @queue = :sms

    class << self
      def perform(phone_number, sms_message)
      end
    end

  end
end
