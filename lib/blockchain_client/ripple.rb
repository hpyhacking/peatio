# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Ripple < Base
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server)
    end

    def endpoint
      @json_rpc_endpoint
    end

    def to_address(tx)
      normalize_address(tx['Destination'])
    end

    def from_address(tx)
      normalize_address(tx['Account'])
    end

    def build_transaction(tx:, currency:)
      {
        id: normalize_txid(tx.fetch('hash')),
        entries:       build_entries(tx, currency)
      }
    end

    def build_entries(tx, currency)
      [
        {
          amount:  convert_from_base_unit(tx.fetch('Amount'), currency)
        }
      ]
    end

    def inspect_address!(address)
      {
        address:  normalize_address(address),
        is_valid: valid_address?(normalize_address(address))
      }
    end

    def calculate_confirmations(tx, ledger_index = nil)
      ledger_index ||= tx.fetch('ledger_index')
      latest_block_number - ledger_index
    end

    def fetch_transactions(ledger_index)
      json_rpc(
        :ledger,
        [{
          "ledger_index": ledger_index || 'validated',
          "transactions": true,
          "expand": true
        }]
      ).dig('result', 'ledger', 'transactions') || []
    end

    def latest_block_number
      Rails.cache.fetch :latest_ripple_ledger, expires_in: 5.seconds do
        response = json_rpc(:ledger, [{ "ledger_index": 'validated' }])
        response.dig('result', 'ledger_index').to_i
      end
    end

    def destination_tag_from(address)
      address =~ /\?dt=(\d*)\Z/
      $1.to_i
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
      body = {
        jsonrpc: '1.0',
        id: @json_rpc_call_id += 1,
        method: method,
        params: [params].flatten
      }.to_json

      headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      connection.post('/', body, headers).yield_self do |response|
        response.assert_success!.yield_self do |response|
          JSON.parse(response.body).tap do |response|
            response.dig('result', 'error').tap do |error|
              raise Error, error.inspect if error.present?
            end
          end
        end
      end
    end

    def normalize_address(address)
      super(address.gsub(/\?dt=\d*\Z/, ''))
    end

    def valid_address?(address)
      /\Ar[0-9a-zA-Z]{33}(:?\?dt=[1-9]\d*)?\z/.match?(address)
    end
  end
end
