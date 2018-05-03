require 'cgi'

module CoinAPI
  class BitGo < BaseAPI
    def initialize(*)
      super
      currency_code_prefix = currency.bitgo_test_net? ? 't' : ''
      @endpoint            = currency.bitgo_rest_api_root!.gsub(/\/+\z/, '') + '/' + currency_code_prefix + currency.code
      @access_token        = currency.bitgo_rest_api_access_token!
    end

    def load_balance!
      convert_from_base_unit(wallet_details(true).fetch('balanceString'))
    end

    # The implementation doesn't return address immediately for ETH.
    # See https://www.bitgo.com/api/v2/#ethereum
    #
    # In this case you should first issue POST for generating new address.
    # See https://www.bitgo.com/api/v2/#create-wallet-address
    #
    # Then you should save BitGo address ID and issue GET request for retrieving new address.
    # See https://www.bitgo.com/api/v2/#get-wallet-address
    #
    def create_address!(options = {})
      if options[:address_id].present?
        path = '/wallet/' + urlsafe_wallet_id + '/address/' + escape_path_component(options[:address_id])
        rest_api(:get, path).slice('address').symbolize_keys
      else
        response = rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/address')
        address  = response['address']
        { address: address.present? ? normalize_address(address) : nil, bitgo_address_id: response['id'] }
      end
    end

    def each_deposit!(options = {})
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit }
      end
    end

    def each_deposit(options = {})
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit }
      end
    end

    def load_deposit!(txid)
      rest_api(:get, '/wallet/' + urlsafe_wallet_id + '/tx/' + normalize_txid(txid))
        .yield_self { |tx| build_deposit(tx) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      fee = options.key?(:fee) ? convert_to_base_unit!(options[:fee]) : nil
      rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/sendcoins', {
        address:          normalize_address(recipient.fetch(:address)),
        amount:           convert_to_base_unit!(amount).to_s,
        feeRate:          fee,
        walletPassphrase: currency.bitgo_wallet_passphrase
      }.compact).fetch('txid').yield_self(&method(:normalize_txid))
    end

    def inspect_address!(address)
      { address: normalize_address(address), is_valid: :unsupported }
    end

  private

    def rest_api(verb, path, data = nil)
      args = [@endpoint + path]

      if data
        if verb.in?(%i[ post put patch ])
          args << data.compact.to_json
          args << { 'Content-Type' => 'application/json' }
        else
          args << data.compact
          args << {}
        end
      else
        args << nil
        args << {}
      end

      args.last['Accept']        = 'application/json'
      args.last['Authorization'] = 'Bearer ' + @access_token

      response = Faraday.send(verb, *args)
      Rails.logger.debug { response.describe }
      response.assert_success!
      JSON.parse(response.body)
    end

    def wallet_details
      rest_api(:get, '/wallet/' + urlsafe_wallet_id)
    end
    memoize :wallet_details

    def urlsafe_wallet_address
      CGI.escape(normalize_address(currency.bitgo_wallet_address))
    end

    def wallet_id
      currency.bitgo_wallet_id
    end

    def urlsafe_wallet_id
      escape_path_component(wallet_id)
    end

    def escape_path_component(id)
      CGI.escape(id)
    end

    def build_deposit(tx)
      entries = build_deposit_entries(tx)
      return if entries.blank?
      { id:            normalize_txid(tx.fetch('id')),
        confirmations: tx.fetch('confirmations').to_i,
        entries:       entries,
        received_at:   Time.parse(tx.fetch('date')) }
    end

    def build_deposit_entries(tx)
      tx.fetch('entries')
        .map do |entry|
          next unless entry['wallet'] == wallet_id
          next unless entry['valueString'].to_d > 0
          next if currency.code.xrp? && tx['destinationTag'].blank?
          next if entry.key?('outputs') && entry['outputs'] != 1
          entry
        end
        .compact
        .map do |entry|
          { amount:  convert_from_base_unit(entry.fetch('valueString')),
            address: normalize_address(entry.fetch('address')) }
        end
    end

    def each_batch_of_deposits(raise = true)
      next_batch_ref = nil
      collected      = []
      loop do
        begin
          batch_deposits = nil
          query          = { limit: 100, nextBatchPrevId: next_batch_ref }
          response       = rest_api(:get, '/wallet/' + urlsafe_wallet_id + '/tx', query)
          next_batch_ref = response['nextBatchPrevId']
          batch_deposits = response.fetch('transactions')
                                   .map { |tx| build_deposit(tx) }
                                   .compact
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits
        collected += batch_deposits
        break if next_batch_ref.blank?
      end
      collected
    end
  end
end
