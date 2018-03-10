module APIv2

  module ExceptionHandlers

    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          error!({ error: { code: 1001, message: e.message } }, 422)
        end
      end
    end

  end

  class Error < Grape::Exceptions::Base
    attr :code, :text

    # code: api error code defined by Peatio, errors originated from
    # subclasses of Error have code start from 2000.
    # text: human readable error message
    # status: http status code
    def initialize(opts={})
      @code    = opts[:code]   || 2000
      @text    = opts[:text]   || ''

      @status  = opts[:status] || 400
      @message = {error: {code: @code, message: @text}}
    end
  end

  class AuthorizationError < Error
    attr_reader :reason

    def initialize(reason = nil)
      @reason = reason
      super code: 2001, text: 'Authorization failed', status: 401
    end
  end

  class CreateOrderError < Error
    def initialize(e)
      super code: 2002, text: "Failed to create order. Reason: #{e}", status: 422
    end
  end

  class CancelOrderError < Error
    def initialize(e)
      super code: 2003, text: "Failed to cancel order. Reason: #{e}", status: 422
    end
  end

  class OrderNotFoundError < Error
    def initialize(id)
      super code: 2004, text: "Order##{id} doesn't exist.", status: 404
    end
  end

  class DepositByTxidNotFoundError < Error
    def initialize(txid)
      super code: 2012, text: "Deposit##txid=#{txid} doesn't exist.", status: 404
    end
  end
end
