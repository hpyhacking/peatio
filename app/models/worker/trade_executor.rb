module Worker
  class TradeExecutor
    def process(payload)
      ::Matching::Executor.new(payload.symbolize_keys).execute
    end
  end
end
