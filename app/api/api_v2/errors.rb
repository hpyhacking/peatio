module APIv2

  module ExceptionHandlers

    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          Rack::Response.new({
            error: {
              code: 1001,
              message: e.message
            }
          }.to_json, e.status)
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
    def initialize
      super code: 2001, text: 'Authorization failed', status: 401
    end
  end

  class CreateOrderError < Error
    def initialize(e)
      super code: 2002, text: "Failed to create order. Reason: #{e}", status: 400
    end
  end

  class CancelOrderError < Error
    def initialize(e)
      super code: 2003, text: "Failed to cancel order. Reason: #{e}", status: 400
    end
  end

  class OrderNotFoundError < Error
    def initialize(id)
      super code: 2004, text: "Order##{id} doesn't exist.", status: 404
    end
  end

  class IncorrectSignatureError < Error
    def initialize(signature)
      super code: 2005, text: "Signature #{signature} is incorrect.", status: 401
    end
  end

  class TonceUsedError < Error
    def initialize(access_key, tonce)
      super code: 2006, text: "The tonce #{tonce} has already been used by access key #{access_key}.", status: 401
    end
  end

  class InvalidTonceError < Error
    def initialize(tonce, now)
      super code: 2007, text: "The tonce #{tonce} is invalid, current timestamp is #{now}.", status: 401
    end
  end

  class InvalidAccessKeyError < Error
    def initialize(access_key)
      super code: 2008, text: "The access key #{access_key} does not exist.", status: 401
    end
  end

  class DisabledAccessKeyError < Error
    def initialize(access_key)
      super code: 2009, text: "The access key #{access_key} is disabled.", status: 401
    end
  end

  class ExpiredAccessKeyError < Error
    def initialize(access_key)
      super code: 2010, text: "The access key #{access_key} has expired.", status: 401
    end
  end

  class OutOfScopeError < Error
    def initialize
      super code: 2011, text: "Requested API is out of access key scopes.", status: 401
    end
  end

  class DepositByTxidNotFoundError < Error
    def initialize(txid)
      super code: 2012, text: "Deposit##txid=#{txid} doesn't exist.", status: 404
    end
  end
end
