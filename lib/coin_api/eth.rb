module CoinAPI
  class ETH < BaseAPI
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint!)
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { Passgen.generate(length: 64, symbols: true) }
      secret.yield_self do |password|
        { address: normalize_address(json_rpc(:personal_newAccount, [password]).fetch('result')),
          secret:  password }
      end
    end

    def load_balance!
      PaymentAddress
        .where(currency: currency)
        .where(PaymentAddress.arel_table[:address].is_not_blank)
        .pluck(:address)
        .reject(&:blank?)
        .map(&method(:load_balance_of_address))
        .reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total) : 0.to_d }
    end

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: valid_address?(normalize_address(address)) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)
      json_rpc(
        :eth_sendTransaction,
        [{
          from:  normalize_address(issuer.fetch(:address)),
          to:    normalize_address(recipient.fetch(:address)),
          value: '0x' + convert_to_base_unit!(amount).to_s(16),
          gas:   options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil
        }.compact]
      ).fetch('result').yield_self do |txid|
        raise CoinAPI::Error, \
          "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end

    def each_deposit!(options = {})
      each_batch_of_deposits raise: true, **options do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def each_deposit(options = {})
      each_batch_of_deposits raise: false, **options do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def load_deposit!(txid)
      json_rpc(:eth_getTransactionByHash, [normalize_txid(txid)]).fetch('result').yield_self do |tx|
        break if tx.blank?
        block = block_information(tx.fetch('blockNumber'))
        { id:            normalize_txid(tx.fetch('hash')),
          confirmations: latest_block_number - tx.fetch('blockNumber').hex,
          received_at:   Time.at(block.fetch('timestamp').hex),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('value').hex),
                            address: normalize_address(tx.fetch('to')) }] }
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

    # See important links:
    #   – https://ethereum.stackexchange.com/questions/25389/getting-transaction-history-for-a-particular-account
    #   – https://github.com/ethereum/go-ethereum/issues/2104#issuecomment-168748944
    #   – https://github.com/ethereum/web3.js/issues/580
    def each_batch_of_deposits(raise:, **options)
      blocks_limit       = options.fetch(:blocks_limit) { 0 }
      transactions_limit = options.fetch(:transactions_limit) { 0 }
      collected          = []
      latest_block_n     = latest_block_number
      current_block_n    = latest_block_n
      latest_block_json  = nil
      current_block_json = nil
      transactions_n     = 0

      while current_block_n > 0
        break unless blocks_limit.zero? || (latest_block_n - current_block_n) <= blocks_limit
        break unless transactions_limit.zero? || transactions_n < transactions_limit
        begin
          deposits            = nil
          block_json          = json_rpc(:eth_getBlockByNumber, ["0x#{current_block_n.to_s(16)}", true]).fetch('result')
          current_block_json  = block_json
          latest_block_json   = block_json if latest_block_n == current_block_n
          transactions_n     += block_json.fetch('transactions').count
          deposits            = build_deposit_collection(block_json['transactions'], current_block_json, latest_block_json)
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield deposits if deposits && block_given?
        collected       += deposits
        current_block_n -= 1
      end

      collected
    end

    def build_deposit_collection(txs, current_block, latest_block)
      txs.map do |tx|
        # Skip contract creation transactions.
        next if tx['to'].blank?

        # Skip outcomes (less than zero) and contract transactions (zero).
        next if tx.fetch('value').hex.to_d <= 0

        { id:            normalize_txid(tx.fetch('hash')),
          confirmations: latest_block.fetch('number').hex - current_block.fetch('number').hex,
          received_at:   Time.at(current_block.fetch('timestamp').hex),
          entries:       [{ amount:  convert_from_base_unit(tx.fetch('value').hex),
                            address: normalize_address(tx['to']) }] }
      end.compact
    end

    def latest_block_number
      Rails.cache.fetch :latest_ethereum_block_number, expires_in: 5.seconds do
        json_rpc(:eth_blockNumber).fetch('result').hex
      end
    end

    def block_information(number)
      json_rpc(:eth_getBlockByNumber, [number, false]).fetch('result')
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise CoinAPI::Error, \
            "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end

    def load_balance_of_address(address)
      json_rpc(:eth_getBalance, [normalize_address(address), 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
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

    def valid_address?(address)
      address.to_s.match?(/\A0x[A-F0-9]{40}\z/i)
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end
  end
end
