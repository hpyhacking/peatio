module CoinAPI
  class BTC < BaseAPI
    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def load_balance!
      json_rpc(:getbalance).fetch('result').to_d
    end

    def each_deposit!
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit }
      end
    end

    def each_deposit
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit }
      end
    end

    def load_deposit!(txid)
      json_rpc(:gettransaction, [txid]).fetch('result').yield_self do |tx|
        tx_details = tx.fetch('details').find { |x| x.fetch('category') == 'receive' }
        return unless tx_details
        { id:            tx.fetch('txid'),
          amount:        tx_details.fetch('amount').to_d,
          confirmations: tx.fetch('confirmations').to_i,
          address:       tx_details.fetch('address'),
          received_at:   Time.at(tx.fetch('timereceived'))
        }.compact
      end
    end

    def create_address!
      { address: json_rpc(:getnewaddress).fetch('result') }
    end

    def create_withdrawal!(issuer, recipient, amount, fee)
      json_rpc(:settxfee, [fee])
      json_rpc(:sendtoaddress, [recipient.fetch(:address), amount]).fetch('result')
    end

    def inspect_address!(address)
      json_rpc(:validateaddress, [address]).fetch('result').yield_self do |x|
        { address:  address,
          is_valid: !!x['isvalid'],
          is_mine:  !!x['ismine'] || PaymentAddress.where(currency: currency.id, address: address).exists? }
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

    def load_deposits
      json_rpc(:listtransactions, [0]).fetch('result')
    end

    def each_batch_of_deposits(raise = true)
      offset    = 0
      collected = []
      loop do
        begin
          batch_deposits = nil
          response       = json_rpc(:listtransactions, ['*', 100, offset])
          offset        += 100
          batch_deposits = response.fetch('result').map { |tx| build_deposit(tx) }.compact
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits
        break if batch_deposits.empty?
      end
      collected
    end

    def build_deposit(tx)
      return if tx.fetch('category') != 'receive'
      { id:            tx.fetch('txid'),
        confirmations: tx.fetch('confirmations').to_i,
        received_at:   Time.at(tx.fetch('timereceived')),
        entries:       [{ amount: tx.fetch('amount').to_d, address:tx.fetch('address') }] }
    end
  end
end
