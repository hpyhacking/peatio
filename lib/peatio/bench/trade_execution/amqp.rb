# frozen_string_literal: true

module Bench
  module TradeExecution
    class AMQP < Matching::AMQP
      def run!
        # TODO: Check if TradeExecutor daemon is running before start (use queue_info[:consumers]).
        super
        Kernel.puts 'Waiting for trades processing by trade execution daemon...'
        @execution_started_at = @publish_started_at
        wait_for_execution
        @execution_finished_at = Time.now
      end

      def wait_for_execution
        last_log_time = Time.at(0)
        queue_status_file = File.open(queue_status_file_path('trade-execution'), 'a')

        loop do
          queue_status = trade_execution_queue_status
          # NOTE: If no orders where matched idle_since would not change.
          break if queue_status[:messages].zero? &&
                  queue_status[:idle_since].present? &&
                  Time.parse("#{queue_status[:idle_since]} UTC") >= @execution_started_at

          if last_log_time + 5 < Time.now
            queue_status_file.puts(YAML.dump([queue_status.merge(timestamp: Time.now.iso8601).deep_stringify_keys]))
            last_log_time = Time.now
          end

          sleep 0.5
        end
      end

      def result
        @result ||=
          begin
            trades_number = Trade.where('created_at >= ?', @publish_started_at).length
            trades_ops = trades_number / (@execution_finished_at - @execution_started_at)

            super.merge(
              trade_execution: {
                started_at:  @execution_started_at.iso8601(6),
                finished_at: @execution_finished_at.iso8601(6),
                operations:  trades_number,
                ops:         trades_ops
              }
            )
          end
      end

      private
      def trade_execution_queue_status
        @rmq_http_client.list_queues.find { |q| q[:name] == AMQP::Config.binding_queue(:trade_executor).first }
      end
    end
  end
end
