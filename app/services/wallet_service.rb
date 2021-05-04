class WalletService
  attr_reader :wallet, :adapter

  def initialize(wallet)
    @wallet = wallet
    @adapter = Peatio::Wallet.registry[wallet.gateway.to_sym].new(wallet.settings.symbolize_keys)
  end

  def create_address!(uid, pa_details)
    blockchain_currency = BlockchainCurrency.find_by(currency_id: @wallet.currencies.map(&:id),
                                                     blockchain_key: @wallet.blockchain_key)

    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)
    @adapter.create_address!(uid: uid, pa_details: pa_details)
  end

  def build_withdrawal!(withdrawal)
    blockchain_currency = BlockchainCurrency.find_by(currency: withdrawal.currency,
                                                     blockchain_key: @wallet.blockchain_key)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)
    transaction = Peatio::Transaction.new(to_address: withdrawal.rid,
                                          amount:     withdrawal.amount,
                                          currency_id: withdrawal.currency_id,
                                          options: { tid: withdrawal.tid })
    transaction = @adapter.create_transaction!(transaction)
    save_transaction(transaction.as_json.merge(from_address: @wallet.address), withdrawal) if transaction.present?
    transaction
  end

  def spread_deposit(deposit)
    blockchain_currency = BlockchainCurrency.find_by(currency: deposit.currency,
                                                     blockchain_key: @wallet.blockchain_key)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)

    destination_wallets =
      Wallet.active.withdraw.ordered
        .joins(:currencies).where(currencies: { id: deposit.currency_id }, blockchain_key: @wallet.blockchain_key)
        .map do |w|
        # NOTE: Consider min_collection_amount is defined per wallet.
        #       For now min_collection_amount is currency config.
        { address:                 w.address,
          balance:                 w.current_balance(deposit.currency),
          # Wallet max_balance will be in the platform currency
          max_balance:             (w.max_balance / deposit.currency.get_price.to_d).round(deposit.currency.precision, BigDecimal::ROUND_DOWN),
          min_collection_amount:   blockchain_currency.min_collection_amount,
          skip_deposit_collection: w.service.skip_deposit_collection?,
          plain_settings:          w.plain_settings }
      end
    raise StandardError, "destination wallets don't exist" if destination_wallets.blank?

    # Since last wallet is considered to be the most secure we need always
    # have it in spread even if we don't know the balance.
    # All money which doesn't fit to other wallets will be collected to cold.
    # That is why cold wallet balance is considered to be 0 because there is no
    destination_wallets.last[:balance] = 0

    # Remove all wallets not available current balance
    # (except the last one see previous comment).
    destination_wallets.reject! { |dw| dw[:balance] == Wallet::NOT_AVAILABLE }

    spread_between_wallets(deposit, destination_wallets)
  end

  # TODO: We don't need deposit_spread anymore.
  def collect_deposit!(deposit, deposit_spread)
    blockchain_currency = BlockchainCurrency.find_by(currency: deposit.currency,
                                                     blockchain_key: @wallet.blockchain_key)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)

    pa = PaymentAddress.find_by(wallet_id: @wallet.id, member: deposit.member, address: deposit.address)
    # NOTE: Deposit wallet configuration is tricky because wallet URI
    #       is saved on Wallet model but wallet address and secret
    #       are saved in PaymentAddress.
    @adapter.configure(
      wallet: @wallet.to_wallet_api_settings
                     .merge(pa.details.symbolize_keys)
                     .merge(address: pa.address)
                     .tap { |s| s.merge!(secret: pa.secret) if pa.secret.present? }
                     .compact
    )

    deposit_spread.map do |transaction|
      # In #spread_deposit valid transactions saved with pending state
      if transaction.status.pending?
        transaction = @adapter.create_transaction!(transaction, subtract_fee: true)
        save_transaction(transaction.as_json.merge(from_address: deposit.address), deposit) if transaction.present?
      end
      transaction
    end
  end

  # TODO: We don't need deposit_spread anymore.
  def deposit_collection_fees!(deposit, deposit_spread)
    blockchain_currency = BlockchainCurrency.find_by(currency: deposit.currency,
                                                     blockchain_key: @wallet.blockchain_key)
    configs = {
      wallet:   @wallet.to_wallet_api_settings,
      currency: blockchain_currency.to_blockchain_api_settings(withdrawal_gas_speed=false)
    }

    if blockchain_currency.parent_id?
      configs.merge!(parent_currency: blockchain_currency.parent.to_blockchain_api_settings)
    end

    @adapter.configure(configs)
    deposit_transaction = Peatio::Transaction.new(hash:         deposit.txid,
                                                  txout:        deposit.txout,
                                                  to_address:   deposit.address,
                                                  block_number: deposit.block_number,
                                                  amount:       deposit.amount)

    transactions = @adapter.prepare_deposit_collection!(deposit_transaction,
                                                        # In #spread_deposit valid transactions saved with pending state
                                                        deposit_spread.select { |t| t.status.pending? },
                                                        blockchain_currency.to_blockchain_api_settings)

    if transactions.present?
      updated_spread = deposit.spread.map do |s|
        deposit_options = s.fetch(:options, {}).symbolize_keys
        transaction_options = transactions.first.options.presence || {}
        general_options = deposit_options.merge(transaction_options)

        s.merge(options: general_options)
      end

      deposit.update(spread: updated_spread)

      transactions.each { |t| save_transaction(t.as_json.merge(from_address: @wallet.address), deposit) }
    end
    transactions
  end

  def refund!(refund)
    blockchain_currency = BlockchainCurrency.find_by(currency: refund.deposit.currency,
                                                     blockchain_key: @wallet.blockchain_key)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)

    pa = PaymentAddress.find_by(wallet_id: @wallet.id, member: refund.deposit.member, address: refund.deposit.address)
    # NOTE: Deposit wallet configuration is tricky because wallet URI
    #       is saved on Wallet model but wallet address and secret
    #       are saved in PaymentAddress.
    @adapter.configure(
      wallet: @wallet.to_wallet_api_settings
                     .merge(pa.details.symbolize_keys)
                     .merge(address: pa.address)
                     .tap { |s| s.merge!(secret: pa.secret) if pa.secret.present? }
                     .compact
    )

    refund_transaction = Peatio::Transaction.new(to_address: refund.address,
                                                 amount: refund.deposit.amount,
                                                 currency_id: refund.deposit.currency_id)
    @adapter.create_transaction!(refund_transaction, subtract_fee: true)
  end

  def load_balance!(currency)
    blockchain_currency = BlockchainCurrency.find_by(currency: currency,
                                                     blockchain_key: @wallet.blockchain_key)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)
    @adapter.load_balance!
  rescue Peatio::Wallet::Error => e
    report_exception(e)
    BlockchainService.new(wallet.blockchain).load_balance!(@wallet.address, currency.id)
  end

  def register_webhooks!(url)
    @adapter.register_webhooks!(url)
  end

  def fetch_transfer!(id)
    @adapter.fetch_transfer!(id)
  end

  def trigger_webhook_event(event)
    # If there are erc20 currencies system should configure parent currency here
    blockchain_currency = BlockchainCurrency.find_by(currency_id: @wallet.currencies.map(&:id),
                                                     blockchain_key: @wallet.blockchain_key,
                                                     parent_id: nil)
    @adapter.configure(wallet:   @wallet.to_wallet_api_settings,
                       currency: blockchain_currency.to_blockchain_api_settings)

    @adapter.trigger_webhook_event(event)
  end

  def skip_deposit_collection?
    @adapter.features[:skip_deposit_collection]
  end

  private

  # @return [Array<Peatio::Transaction>] result of spread in form of
  # transactions array with amount and to_address defined.
  def spread_between_wallets(deposit, destination_wallets)
    original_amount = deposit.amount
    if original_amount < destination_wallets.pluck(:min_collection_amount).min
      return []
    end

    left_amount = original_amount

    spread = destination_wallets.map do |dw|
      amount_for_wallet = [dw[:max_balance] - dw[:balance], left_amount].min

      # If free amount in current wallet is too small,
      # we will not able to collect it.
      # Put 0 for this wallet.
      if amount_for_wallet < [dw[:min_collection_amount], 0].max
        amount_for_wallet = 0
      end

      left_amount -= amount_for_wallet

      # If amount left is too small we will not able to collect it.
      # So we collect everything to current wallet.
      if left_amount < dw[:min_collection_amount]
        amount_for_wallet += left_amount
        left_amount = 0
      end

      transaction_params = { to_address:  dw[:address],
                             amount: amount_for_wallet.to_d,
                             currency_id: deposit.currency_id,
                             options:     dw[:plain_settings]
                           }.compact

      transaction = Peatio::Transaction.new(transaction_params)

      # Tx will not be collected to this destination wallet
      transaction.status = :skipped if dw[:skip_deposit_collection]
      transaction
    rescue => e
      # If have exception skip wallet.
      report_exception(e)
    end

    if left_amount > 0
      # If deposit doesn't fit to any wallet, collect it to the last one.
      # Since the last wallet is considered to be the most secure.
      spread.last.amount += left_amount
      left_amount = 0
    end

    # Remove zero and skipped transactions from spread.
    spread.filter { |t| t.amount > 0 }.tap do |sp|
      unless sp.map(&:amount).sum == original_amount
        raise Error, "Deposit spread failed deposit.amount != collection_spread.values.sum"
      end
    end
  end

  # Record blockchain transactions in DB
  def save_transaction(transaction, reference)
    transaction['txid'] = transaction.delete('hash')
    Transaction.create!(transaction.merge(reference: reference))
  end
end
