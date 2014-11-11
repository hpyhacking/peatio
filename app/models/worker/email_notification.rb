module Worker
  class EmailNotification
    include AMQPQueue::Worker

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      super(payload)

      mailer = payload[:mailer_class].constantize
      action = payload[:method]
      args   = payload[:args]

      message = mailer.send(:new, action, *args).message
      message.deliver
    end

  end
end
