module Worker
  class EmailNotification

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      set_locale(payload)

      mailer = payload[:mailer_class].constantize
      action = payload[:method]
      args   = payload[:args]

      message = mailer.send(:new, action, *args).message
      message.deliver
    end

    private

    def set_locale(payload)
      locale = payload[:locale]
      I18n.locale = locale if locale
    end

  end
end
