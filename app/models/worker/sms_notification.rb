module Worker
  class SmsNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      ChinaSMS.use :juxin, username: ENV['JUXIN_USERNAME'], password: ENV['JUXIN_PASSWORD']
      ChinaSMS.to payload[:phone], payload[:message]
    end

  end
end
