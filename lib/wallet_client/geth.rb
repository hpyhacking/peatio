# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Geth < Base

    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(wallet.uri)
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { Passgen.generate(length: 64, symbols: true) }
      secret.yield_self do |password|
        { address: normalize_address(json_rpc(:personal_newAccount, [password]).fetch('result')),
          secret:  password }
      end
    end

    def create_eth_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)
      json_rpc(
          :eth_sendTransaction,
          [{
               from:     normalize_address(issuer.fetch(:address)),
               to:       normalize_address(recipient.fetch(:address)),
               value:    '0x' + amount.to_s(16),
               gas:      options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil,
               gasPrice: options.key?(:gas_price) ? '0x' + options[:gas_price].to_s(16) : nil
           }.compact]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end

    def create_erc20_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)

      data = abi_encode \
        'transfer(address,uint256)',
        normalize_address(recipient.fetch(:address)),
        '0x' + amount.to_s(16)

      json_rpc(
          :eth_sendTransaction,
          [{
               from: normalize_address(issuer.fetch(:address)),
               to:   options[:contract_address],
               data: data
           }]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise WalletClient::Error, \
            "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: valid_address?(normalize_address(address)) }
    end

    def normalize_address(address)
      address.downcase
    end

    def normalize_txid(txid)
      txid.downcase
    end

    protected

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def abi_explode(data)
      data = data.gsub(/\A0x/, '')
      { method:    '0x' + data[0...8],
        arguments: data[8..-1].chars.in_groups_of(64, false).map { |group| '0x' + group.join } }
    end

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
        { jsonrpc: '2.0', id: @json_rpc_call_id += 1, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def valid_address?(address)
      address.to_s.match?(/\A0x[A-F0-9]{40}\z/i)
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end
  end
end
