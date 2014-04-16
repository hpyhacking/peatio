module Worker
  class TradeExecutor

    def process(payload)
      payload.symbolize_keys!
      ::Matching::Executor.new(payload).execute!
    end

  end
end
