# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class TradeExecutor < Base
      def process(payload)
        ::Matching::Executor.new(payload.symbolize_keys).process
      end
    end
  end
end
