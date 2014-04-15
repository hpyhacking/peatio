class AMQPQueue

  class <<self
    def connection
      @connection ||= Bunny.new(AMQP_CONFIG[:connect]).tap do |conn|
        conn.start
      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchanges
      @exchanges ||= {default: channel.default_exchange}
    end

    def exchange(id)
      exchanges[id] ||= channel.send(AMQP_CONFIG[:exchange][id][:type], AMQP_CONFIG[:exchange][id][:name])
    end

    def publish(eid, payload, attrs={})
      payload = JSON.dump payload
      exchange(eid).publish(payload, attrs)
    end

    # 1-1 mapping, use default exchange
    def enqueue(qid, payload)
      publish(:default, payload, routing_key: AMQP_CONFIG[:queue][qid])
    end
  end

  module Mailer
    class <<self
      def included(base)
        base.extend(ClassMethods)
      end

      def excluded_environment?(name)
        [:test].include?(name.try(:to_sym))
      end
    end

    module ClassMethods

      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          MessageDecoy.new(self, method_name, *args)
        else
          super
        end
      end

      def deliver?
        true
      end
    end

    class MessageDecoy
      delegate :to_s, :to => :actual_message

      def initialize(mailer_class, method_name, *args)
        @mailer_class = mailer_class
        @method_name = method_name
        *@args = *args
        actual_message if environment_excluded?
      end

      def environment_excluded?
        !ActionMailer::Base.perform_deliveries || ::AMQPQueue::Mailer.excluded_environment?(Rails.env)
      end

      def actual_message
        @actual_message ||= @mailer_class.send(:new, @method_name, *@args).message
      end

      def deliver
        return deliver! if environment_excluded?

        if @mailer_class.deliver?
          begin
            AMQPQueue.enqueue(:mailer, mailer_class: @mailer_class.to_s, method: @method_name, args: @args)
          rescue
            Rails.logger.error "Unable to enqueue :mailer: #{$!}, fallback to synchronous mail delivery"
            deliver!
          end
        end
      end

      def deliver!
        actual_message.deliver
      end

      def method_missing(method_name, *args)
        actual_message.send(method_name, *args)
      end
    end
  end

end
