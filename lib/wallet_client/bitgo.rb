# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bitgo < Base

    def initialize(*)
      super
      currency_code_prefix = wallet.bitgo_test_net ? 't' : ''
      @endpoint            = wallet.bitgo_rest_api_root.gsub(/\/+\z/, '') + '/' + currency_code_prefix + wallet.currency.code
      @access_token        = wallet.bitgo_rest_api_access_token
    end

    def create_address!(options = {})
      if options[:address_id].present?
        path = '/wallet/' + urlsafe_wallet_id + '/address/' + escape_path_component(options[:address_id])
        rest_api(:get, path).slice('address').symbolize_keys
      else
        response = rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/address', options.slice(:label))
        address  = response['address']
        { address: address.present? ? normalize_address(address) : nil, bitgo_address_id: response['id'] }
      end
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      fee = options.key?(:fee) ? convert_to_base_unit!(options[:fee]) : nil
      rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/sendcoins', {
          address:          normalize_address(recipient.fetch(:address)),
          amount:           convert_to_base_unit!(amount).to_s,
          feeRate:          fee,
          walletPassphrase: bitgo_wallet_passphrase
      }.compact).fetch('txid').yield_self(&method(:normalize_txid))
    end

    def build_raw_transaction(recipient, amount)
      rest_api(:post, '/wallet/' + urlsafe_wallet_id + '/tx/build', {
          recipients: [{address: normalize_address(recipient.fetch(:address)), amount: convert_to_base_unit!(amount).to_s }]
      }.compact, false).fetch('feeInfo').fetch('fee').yield_self(&method(:convert_from_base_unit))
    end

    def inspect_address!(address)
      { address: normalize_address(address), is_valid: :unsupported }
    end

    # Note: bitgo doesn't accept cash address format
    def normalize_address(address)
      wallet.blockchain_api&.supports_cash_addr_format? ? CashAddr::Converter.to_legacy_address(super) : super
    end

    protected

    def rest_api(verb, path, data = nil, raise_error = true)
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
      response.assert_success! if raise_error
      JSON.parse(response.body)
    end

    def wallet_details
      rest_api(:get, '/wallet/' + urlsafe_wallet_id)
    end

    def urlsafe_wallet_address
      CGI.escape(normalize_address(wallet.address))
    end

    def wallet_id
      wallet.bitgo_wallet_id
    end

    def bitgo_wallet_passphrase
      wallet.bitgo_wallet_passphrase
    end

    def urlsafe_wallet_id
      escape_path_component(wallet_id)
    end

    def escape_path_component(id)
      CGI.escape(id)
    end

  end
end
