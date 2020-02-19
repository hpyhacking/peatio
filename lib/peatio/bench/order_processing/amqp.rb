# frozen_string_literal: true

module Bench
  module OrderProcessing
    class AMQP < TradeExecution::AMQP
      def run!
        # TODO: Check if OrderProcessing daemon is running before start (use queue_info[:consumers]).
        super
        Kernel.puts "Init wait orders queue..."
        @orders_for_cancel_number = init_wait_orders_queue!.size # TODO: If zero? raise Error.

        Kernel.puts "Start wait orders publish..."
        @cancel_publish_started_at = @order_processing_started_at = Time.now
        publish_cancel_messages
        @cancel_publish_finished_at = Time.now

        Kernel.puts "Messages are published to RabbitMQ."
        Kernel.puts "Waiting for order processing by order processor..."
        wait_for_order_processing
        @order_processing_finished_at = Time.now
      end

      def publish_cancel_messages
        Array.new(@config[:threads]) do
          Thread.new do
            loop do
              break if @wait_orders_queue.blank?
              order = @wait_orders_queue.pop
              AMQP::Queue.enqueue(:matching, action: 'cancel', order: order.to_matching_attributes)
            rescue StandardError => e
              Kernel.puts e
              @errors << e
            end
          end
        end.map(&:join)
      end

      def wait_for_order_processing
        last_log_time = Time.at(0)
        queue_status_file = File.open(queue_status_file_path('order-processing'), 'a')

        loop do
          queue_status = order_processing_queue_status
          # NOTE: If no orders where cancelled idle_since would not change.
          break if queue_status[:messages].zero? &&
                  queue_status[:idle_since].present? &&
                  Time.parse("#{queue_status[:idle_since]} UTC") >= @order_processing_started_at

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
            cancel_publish_ops = @orders_for_cancel_number / (@cancel_publish_finished_at - @cancel_publish_started_at)
            order_processing_ops = @orders_for_cancel_number / (@order_processing_finished_at - @order_processing_started_at)

            super.merge(
              cancel_publish: {
                started_at:  @cancel_publish_started_at.iso8601(6),
                finished_at: @cancel_publish_finished_at.iso8601(6),
                operations:  @orders_for_cancel_number,
                ops:         cancel_publish_ops
              },
              order_processing: {
                started_at:  @order_processing_started_at.iso8601(6),
                finished_at: @order_processing_finished_at.iso8601(6),
                operations:  @orders_for_cancel_number,
                ops:         order_processing_ops
              }
            )
          end
      end

      private
      def init_wait_orders_queue!
        orders = Order.where(state: Order::WAIT).shuffle
        @wait_orders_queue =
          orders.each_with_object(Queue.new) do |o, queue|
            queue << o
          end
      end

      def order_processing_queue_status
        @rmq_http_client.list_queues.find { |q| q[:name] == AMQP::Config.binding_queue(:order_processor).first }
      end
    end
  end
end
