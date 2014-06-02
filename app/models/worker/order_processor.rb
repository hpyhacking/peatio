module Worker
  class OrderProcessor

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      p payload
    end

  end
end
