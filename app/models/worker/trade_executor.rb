# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class TradeExecutor
    def process(payload)
      ::Matching::Executor.new(payload.symbolize_keys).execute
    end
  end
end
