module Worker
  class SmsNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      ChinaSMS.use :chuangshimandao, username: ENV['CHUANGSHIMANDAO_USERNAME'], password: ENV['CHUANGSHIMANDAO_PASSWORD']
      ChinaSMS.to payload[:phone], payload[:message]
    end

  end
end
