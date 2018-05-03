module CoinAPI
  class XRP < BaseAPI
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def load_balance!
      PaymentAddress
        .where(currency: currency)
        .where(PaymentAddress.arel_table[:address].is_not_blank)
        .pluck(:address)
        .reject(&:blank?)
        .map do |address|

          # NOTE: We need to ignore wallets which are not funded yet (zero balance)
          # since Ripple API handles such wallets as non-existing:
          #
          # {
          #   "result": {
          #     "account": "rU4xnC63VPbjB1tm6LRBo9MaqN3fduGxvq",
          #     "error": "actNotFound",
          #     "error_code": 19,
          #     "error_message": "Account not found.",
          #     "ledger_current_index": 7042738,
          #     "request": {
          #       "account": "rNpg1M34gz2ejR411RdmbKiwZxww13r1aE",
          #       "command": "account_info"
          #     },
          #     "status": "error",
          #     "validated": false
          #   }
          # }
          #
          # (Yaroslav Konoplov)

          json_rpc(:account_info, [account: normalize_address(address), ledger_index: 'validated', strict: true])
            .fetch('result')
            .fetch('account_data')
            .fetch('Balance').to_d
        rescue => e
          report_exception_to_screen(e)
          0.0
        end.reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total) : 0.to_d }
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { Passgen.generate(length: 64, symbols: true) }
      json_rpc(:wallet_propose, [{ passphrase: secret }]).fetch('result').yield_self do |result|
        { address: normalize_address(result.fetch('account_id')), secret: secret }.merge! \
          result.slice('key_type', 'master_seed', 'master_seed_hex', 'master_key', 'public_key', 'public_key_hex')
      end.symbolize_keys!
    end

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: address?(normalize_address(address)) }
    end

    def load_deposit!(txid)
      json_rpc(:tx, [transaction: txid]).fetch('result').yield_self do |tx|
        next unless tx['status'].to_s == 'success'
        next unless tx['validated']
        next unless address?(normalize_address(tx['Destination'].to_s))
        next unless tx['TransactionType'].to_s == 'Payment'
        next unless tx.dig('meta', 'TransactionResult').to_s == 'tesSUCCESS'
        next if tx['DestinationTag'].present?
        next unless String === tx['Amount']

        { id:            tx.fetch('hash'),
          confirmations: calculate_confirmations(tx),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('Amount')),
                            address: normalize_address(tx['Destination']) }] }
      end
    end

    def each_deposit!(options = {})
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def each_deposit(options = {})
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(
        :submit,
        [{
          secret:       issuer.fetch(:secret),
          fee_mult_max: 1000,
          tx_json:      { Account:         normalize_address(issuer.fetch(:address)),
                          Amount:          convert_to_base_unit!(amount),
                          Destination:     normalize_address(recipient.fetch(:address)),
                          TransactionType: 'Payment' }
        }]
      ).fetch('result').yield_self do |result|
        if result['engine_result'].to_s == 'tesSUCCESS' && result['status'].to_s == 'success'
          normalize_txid(result.fetch('tx_json').fetch('hash'))
        else
          raise CoinAPI::Error, "XRP withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed: #{result.fetch('engine_result_message')}."
        end
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
        { jsonrpc: '1.0', id: @json_rpc_call_id += 1, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response.dig('result', 'error').tap { |error| raise Error, error.inspect if error.present? }
      response
    end

    def address?(address)
      /\Ar[0-9a-zA-Z]{33}\z/.match?(address)
    end

    def each_batch_of_deposits(raise = true)
      offset    = 0
      collected = []

      loop do
        begin
          # Nullify variables before running dangerous code.
          response       = nil
          batch_deposits = nil
          response       = json_rpc(:tx_history, [start: offset])
          batch_deposits = build_deposit_collection(response.fetch('result').fetch('txs'))
          offset        += batch_deposits.count
        rescue => e
          report_exception(e)
          raise e if raise
        end
        collected += batch_deposits if batch_deposits
        yield batch_deposits if batch_deposits
        break if response.blank? || !more_deposits_available?(response)
      end
      collected
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        next unless tx['TransactionType'].to_s == 'Payment'
        next unless address?(normalize_address(tx['Destination'].to_s))
        next if tx['DestinationTag'].present?
        next unless String === tx['Amount']

        { id:            normalize_txid(tx.fetch('hash')),
          confirmations: calculate_confirmations(tx),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('Amount')),
                            address: normalize_address(tx['Destination']) }] }
      end.compact
    end

    def more_deposits_available?(response)
      response.fetch('result').fetch('txs').present?
    end

    def calculate_confirmations(tx)
      tx.fetch('LastLedgerSequence') { tx.fetch('ledger_index') } - tx.fetch('inLedger')
    end
  end
end
