# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Ethereum < Base

    TOKEN_EVENT_IDENTIFIER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    SUCCESS = '0x1'

    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server)
    end

    def endpoint
      @json_rpc_endpoint
    end

    def get_block(height)
      current_block   = height || 0
      json_rpc(:eth_getBlockByNumber, ["0x#{current_block.to_s(16)}", true]).fetch('result')
    end

    def to_address(tx)
      if tx.has_key?('logs')
        get_erc20_addresses(tx)
      else
        [normalize_address(tx.fetch('to'))]
      end.compact
    end

    def get_erc20_addresses(tx)
      tx.fetch('logs').map do |log|
        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER
        normalize_address('0x' + log.fetch('topics').last[-40..-1])
      end
    end

    def from_address(tx)
      normalize_address(tx['from'])
    end

    def build_transaction(txn, current_block_json, currency)
      if txn.has_key?('logs')
        build_erc20_transaction(txn, current_block_json, currency)
      else
        build_eth_transaction(txn, current_block_json, currency)
      end
    end

    def latest_block_number
      Rails.cache.fetch :latest_ethereum_block_number, expires_in: 5.seconds do
        json_rpc(:eth_blockNumber).fetch('result').hex
      end
    end

    def invalid_eth_transaction?(block_txn)
      block_txn.fetch('to').blank? \
      || block_txn.fetch('value').hex.to_d <= 0 && block_txn.fetch('input').hex <= 0 \
    end

    def invalid_erc20_transaction?(txn_receipt)
      txn_receipt.fetch('status') != SUCCESS \
      || txn_receipt.fetch('to').blank? \
      || txn_receipt.fetch('logs').blank?
    end

    def get_txn_receipt(txid)
      json_rpc(:eth_getTransactionReceipt, [normalize_txid(txid)]).fetch('result')
    end

    # IMPORTANT: Be sure to set the correct value!
    def case_sensitive?
      false
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
        { jsonrpc: '2.0', id: rpc_call_id, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def rpc_call_id
      @json_rpc_call_id += 1
    end


    def block_information(number)
      json_rpc(:eth_getBlockByNumber, [number, false]).fetch('result')
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise BlockchainClient::Error, \
            "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end

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

    def abi_method(data)
      '0x' + data.gsub(/\A0x/, '')[0...8]
    end

    def valid_address?(address)
      address.to_s.match?(/\A0x[A-F0-9]{40}\z/i)
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end

    def build_eth_transaction(tx, current_block_json, currency)
      { id:            normalize_txid(tx.fetch('hash')),
        block_number:  current_block_json.fetch('number').hex,
        entries:       currency.code.eth? ? build_entries(tx, currency) : [] }
    end

    def build_entries(tx, currency)
      [
        { amount:  convert_from_base_unit(tx.fetch('value').hex, currency),
          address: normalize_address(tx['to'])}
      ]
    end

    def build_erc20_transaction(tx, current_block_json, currency)
      entries = tx.fetch('logs').map do |log|

        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER
        # Skip if ERC20 contract address doesn't match.
        next if tx.fetch('to') != currency.erc20_contract_address

        { amount:  convert_from_base_unit(log.fetch('data').hex, currency),
          address: normalize_address('0x' + log.fetch('topics').last[-40..-1]) }
      end

      { id:            normalize_txid(tx.fetch('transactionHash')),
        block_number: current_block_json.fetch('number').hex,
        entries:       entries.compact }
    end

    def contract_address
      normalize_address(currency.erc20_contract_address)
    end
  end
end
