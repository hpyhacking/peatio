module CoinAPI
  class ETH < BaseAPI
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def create_address!
      Passgen.generate(length: 64, symbols: true).yield_self do |password|
        { address: json_rpc(:personal_newAccount, [password]).fetch('result'), secret: password }
      end
    end

    def load_balance!
      PaymentAddress
        .where(currency: currency.code.downcase)
        .where(PaymentAddress.arel_table[:address].is_not_blank)
        .pluck(:address)
        .reject(&:blank?)
        .map do |address|
          json_rpc(:eth_getBalance, [address, 'latest']).fetch('result').hex.to_d
        rescue => e
          report_exception_to_screen(e)
          0.0
        end.reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total) : 0.to_d }
    end

    def inspect_address!(address)
      { address:  address,
        is_valid: /\A0x[A-F0-9]{40}\z/i.match?(address),
        is_mine:  :unsupported }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)

      json_rpc(
        :eth_sendTransaction,
        [{
          from:  issuer.fetch(:address),
          to:    recipient.fetch(:address),
          value: '0x' + convert_to_base_unit!(amount).to_s(16),
          gas:   options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil
        }.compact]
      ).fetch('result').yield_self do |txid|
        if txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
          txid
        else
          raise CoinAPI::Error, "ETH withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
        end
      end
    end

    def each_deposit!
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def each_deposit
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def load_deposit!(txid)
      json_rpc(:eth_getTransactionByHash, [txid]).fetch('result').yield_self do |tx|
        return if tx.blank?
        block = block_information(tx.fetch('blockNumber'))
        { id:            tx.fetch('hash'),
          confirmations: latest_block_number - tx.fetch('blockNumber').hex,
          received_at:   Time.at(block.fetch('timestamp').hex),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('value').hex),
                            address: tx.fetch('to') }] }
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
        { jsonrpc: '2.0', id: @json_rpc_call_id += 1, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    # https://ethereum.stackexchange.com/questions/25389/getting-transaction-history-for-a-particular-account
    # https://github.com/ethereum/go-ethereum/issues/2104#issuecomment-168748944
    # https://github.com/ethereum/web3.js/issues/580
    def each_batch_of_deposits(raise = true)
      collected       = []
      latest_block_n  = latest_block_number
      current_block_n = latest_block_n
      latest_block    = nil
      current_block   = nil

      while current_block_n > 0
        begin
          batch_deposits = nil
          block          = json_rpc(:eth_getBlockByNumber, ["0x#{current_block_n.to_s(16)}", true]).fetch('result')
          current_block  = block
          latest_block   = block if latest_block_n == current_block_n
          batch_deposits = build_deposit_collection(block.fetch('transactions'), current_block, latest_block)
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits && block_given?
        collected       += batch_deposits
        current_block_n -= 1
      end

      collected
    end

    def build_deposit_collection(txs, current_block, latest_block)
      txs.map do |tx|
        next if tx.fetch('to').blank? || tx.fetch('value').hex.to_d <= 0
        { id:            tx.fetch('hash'),
          confirmations: latest_block.fetch('number').hex - current_block.fetch('number').hex,
          received_at:   Time.at(current_block.fetch('timestamp').hex),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('value').hex),
                            address: tx.fetch('to') }] }
      end.compact
    end

    def latest_block_number
      json_rpc(:eth_blockNumber).fetch('result').hex
    end

    def block_information(number)
      json_rpc(:eth_getBlockByNumber, [number, false]).fetch('result')
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [issuer.fetch(:address), issuer.fetch(:secret), 5]).tap do |response|
        unless response.fetch('result')
          raise CoinAPI::Error, "ETH withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
        end
      end
    end
  end
end
