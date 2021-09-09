module OpendaxCloud
  class Wallet < Peatio::Wallet::Abstract
    Error = Class.new(StandardError)
    DEFAULT_FEATURES = { skip_deposit_collection: true }.freeze

    DEPOSIT_TRANSACTION_STATE_TRANSLATIONS = {
      success: %w[collected],
      rejected: %w[rejected],
      pending: %w[processing fee_processing accepted]
    }.freeze

    WITHDRAW_TRANSACTION_STATE_TRANSLATIONS = {
      success: %w[succeed],
      failed: %w[failed],
      rejected: %w[rejected],
      pending: %w[accepted processing confirming errored]
    }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :address)

      @currency = @settings.fetch(:currency) do
        raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(_options = {})
      response = client.rest_api(:post, '/address/new', {
                                   currency_id: currency_id
                                 })

      { address: response['address'], details: response.except('address') }
    rescue OpendaxCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def create_transaction!(transaction)
      response = client.rest_api(:post, '/tx/send', {
                    currency_id: currency_id,
                    to_address: transaction.to_address,
                    amount: transaction.amount,
                    tid: transaction.options.try(:[], :tid)
                  }.compact)

      transaction.options = { tid: response['tid'] } if response['tid'].present?
      transaction.fee = response['fee']
      transaction.fee_currency_id = currency_id
      transaction
    rescue OpendaxCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def load_balance!
      response = client.rest_api(:post, '/address/balance', {
        currency_id: currency_id
      }.compact).fetch('balance')

      response.to_d
    rescue OpendaxCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def trigger_webhook_event(request)
      # Decode from base64 openfinex_cloud env
      public_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('OPENFINEX_CLOUD_PUBLIC_KEY')))
      # Verify JWT signature
      params = JWT.decode(request.body.string, public_key, true, { algorithm: 'ES256' }).first.with_indifferent_access

      [
        Peatio::Transaction.new(
          currency_id: params[:currency],
          amount: params[:amount].to_d,
          hash: params[:blockchain_txid],
          # If there is no rid field, it means we have deposit in payload
          to_address: params[:rid] || params[:address],
          txout: 0,
          status: translate_state(request.params[:event], params[:state]),
          fee_currency_id: params[:currency],
          fee: params[:fee],
          options: {
            tid: params[:tid]
          })
      ]
    rescue OpendaxCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    # This method will translate deposit/withdraw states
    # to transaction states (rejected, success, penging, rejected)
    def translate_state(event, state)
      # Get transaction state translation which depends on event
      states = OpendaxCloud::Wallet.const_get("#{event.upcase}_TRANSACTION_STATE_TRANSLATIONS")
      res = states.find { |key, values| values.include?(state) }

      # result consists of array [key, [values]]
      res.first if res.present?
    end

    def convert_from_base_unit(value)
      value.to_d / @currency.fetch(:base_factor).to_d
    end

    def currency_id
      @currency.fetch(:id)
    end

    def client
      @client ||= Client.new(@wallet.fetch(:uri), idle_timeout: 1)
    end
  end
end
