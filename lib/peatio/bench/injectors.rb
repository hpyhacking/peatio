# frozen_string_literal: true

module Bench
  module Injectors

    class << self
      def initialize_injector(config)
        "#{self.name}/#{config[:injector]}"
          .camelize
          .constantize
          .new(config)
      end
    end

    class Base
      attr_reader :config

      def initialize(config)
        @config = config
        @number = config[:number].to_i
        @step = config.fetch(:step, 10000).to_i
        @markets = ::Market.where(id: config[:markets].split(',').map(&:squish).reject(&:blank?))
      end

      def generate!(members = nil)
        @members = members || Member.all
        @queue = Queue.new
        Array.new(@number / @step) do
          Rails.logger.info { "Created orders: #{@queue.size}" }
          ActiveRecord::Base.transaction do
            Array.new(@step) do
              create_order.tap { |o| @queue << o }
            end
          end
        end
      end

      def pop
        # Use non_blocking pop.
        @queue.pop(true)
      rescue ThreadError
        # Return nil in case of empty queue.
        nil
      end

      def size
        @queue.size
      end

      private

      def create_order
        Order.new(construct_order)
             .tap(&:round_amount_and_price)
             .tap { |o| o.locked = o.origin_locked = o.compute_locked }
             .tap { |o| o.hold_account!.lock_funds(o.locked) }
             .tap(&:save)
      end

      def construct_order
        method_not_implemented
      end
    end
  end
end

