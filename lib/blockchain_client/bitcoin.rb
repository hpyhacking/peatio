# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Bitcoin < Base
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server)
    end

    def endpoint
      @json_rpc_endpoint
    end

    def load_deposit!(txid)
      json_rpc(:gettransaction, [normalize_txid(txid)]).fetch('result').yield_self { |tx| build_standalone_deposit(tx) }
    end

    def create_address!(options = {})
      { address: normalize_address(json_rpc(:getnewaddress).fetch('result')) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:sendtoaddress, [normalize_address(recipient.fetch(:address)), amount])
        .fetch('result')
        .yield_self(&method(:normalize_txid))
    end

    def latest_block_number
      Rails.cache.fetch "latest_#{self.class.name.underscore}_block_number", expires_in: 5.seconds do
        json_rpc(:getblockcount).fetch('result')
      end
    end

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, 2]).fetch('result')
    end

    def get_block_hash(height)
      current_block   = height || 0
      json_rpc(:getblockhash, [current_block]).fetch('result')
    end

    def to_address(tx)
      tx.fetch('vout').map{|v| normalize_address(v['scriptPubKey']['addresses'][0]) if v['scriptPubKey'].has_key?('addresses')}.compact
    end

    def build_transaction(tx, current_block, address)
      entries = tx.fetch('vout').map do |item|

        next if item.fetch('value').to_d <= 0
        next unless item['scriptPubKey'].has_key?('addresses')
        next if address != normalize_address(item['scriptPubKey']['addresses'][0])

        { amount: item.fetch('value').to_d, address: normalize_address(item['scriptPubKey']['addresses'][0]) }
      end.compact

      { id:            normalize_txid(tx.fetch('txid')),
        block_number:  current_block,
        entries:       entries }
    end

    def get_unconfirmed_txns
      json_rpc(:getrawmempool).fetch('result').map(&method(:get_raw_transaction))
    end

    def get_raw_transaction(txid)
      json_rpc(:getrawtransaction, [txid, true]).fetch('result')
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
