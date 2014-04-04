module APIv2
  class ErrorsFormatter

    def call(message, backtrace, options={}, env=nil)
      result = message.is_a?(Hash) ? message : format(message)
      MultiJson.dump result
    end

    def format(message)
      {error: {code: error_code(message), message: message}}
    end

    # api error code, errors originated from Grape have code start
    # from 1000.
    def error_code(message)
      case message
      when /does not have a valid value$/
        1001
      else
        1000
      end
    end

  end
end
