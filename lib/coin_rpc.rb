module CoinRPC
  JSONRPCError = Class.new(RuntimeError)
  ConnectionRefusedError = Class.new(StandardError)

  def self.[](currency)
    c = Currency.find_by_code(currency.to_s)
    (c.nil? || c.rpc.empty? || c.code.empty?) && raise("RPC url for #{name} not found! Please fix that in `config/currencies.yml`")
    "CoinRPC::#{c.code.upcase}".constantize.new(c)
  end

  class BaseRPC
    def initialize(c)
      @uri = URI.parse(c.rpc)
      @rest_uri = URI.parse(c[:rest_api])
    end

    def handle
      raise 'Not implemented'
    end

    private

    def method_missing(name, *args)
      handle name, *args
    end
  end
end
