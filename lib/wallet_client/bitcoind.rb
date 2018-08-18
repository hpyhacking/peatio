# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bitcoind < Base

    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(wallet.uri)
    end

    def create_address!(options = {})
      { address: normalize_address(json_rpc(:getnewaddress).fetch('result')) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      options.merge!(subtract_fee: false) unless options.has_key?(:subtract_fee)

      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:sendtoaddress, [normalize_address(recipient.fetch(:address)), amount, '', '', options[:subtract_fee]])
          .fetch('result')
          .yield_self(&method(:normalize_txid))
    end

    def inspect_address!(address)
      json_rpc(:validateaddress, [normalize_address(address)]).fetch('result').yield_self do |x|
        { address: normalize_address(address), is_valid: !!x['isvalid'] }
      end
    end

    protected

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        { jsonrpc: '1.0', method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end
  end
end
