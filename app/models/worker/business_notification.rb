module Worker
  class BusinessNotification
      def process(payload, metadata, delivery_info)
        payload.symbolize_keys!

        if payload[:message_class].constantize.method_defined? :take_email_info
          email_info = payload[:message_class].constantize.new.send :take_email_info,payload[:business_id]
          EmailSender.new.send_email(payload[:mailer_class],payload[:method_name],email_info)
        end

        if payload[:message_class].constantize.method_defined? :take_sms_info
          #if member.sms_enabled == 0
          sms_info = payload[:message_class].constantize.new.send :take_sms_info,payload[:business_id]
          SmsSender.new.send_sms(sms_info[0].phone_number,sms_info[1])
        end

      end
  end
end
