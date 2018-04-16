module Worker
  class TradeExecutor

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      ::Matching::Executor.new(payload).execute!
    rescue
      raise $!
    end
  end
end
