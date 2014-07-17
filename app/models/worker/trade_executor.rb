module Worker
  class TradeExecutor

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      ::Matching::Executor.new(payload).execute!
    rescue
      SystemMailer.trade_execute_error(payload, $!.message, $!.backtrace.join("\n")).deliver
      raise $!
    end

  end
end
