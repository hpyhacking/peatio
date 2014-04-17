module Job
  class Sms

    @queue = :sms

    class << self
      def perform(phone_number, sms_message)
        ChinaSMS.use :juxin, username: ENV['JUXIN_USERNAME'], password: ENV['JUXIN_PASSWORD']
        ChinaSMS.to phone_number, sms_message
      end
    end

  end
end
