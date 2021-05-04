class BlockchainService
  Error = Class.new(StandardError)
  BalanceLoadError = Class.new(StandardError)

  attr_reader :blockchain, :whitelisted_smart_contract, :currencies, :adapter

  def initialize(blockchain)
    @blockchain = blockchain
    @blockchain_currencies = blockchain.blockchain_currencies.deposit_enabled
    @currencies = @blockchain_currencies.pluck(:currency_id).uniq
    @whitelisted_addresses = blockchain.whitelisted_smart_contracts.active
    @adapter = Peatio::Blockchain.registry[blockchain.client.to_sym].new
    @adapter.configure(server: @blockchain.server,
                       currencies: @blockchain_currencies.map(&:to_blockchain_api_settings),
                       whitelisted_addresses: @whitelisted_addresses)
  end

  def latest_block_number
    @latest_block_number ||= @adapter.latest_block_number
  end

  def load_balance!(address, currency_id)
    @adapter.load_balance_of_address!(address, currency_id)
  rescue Peatio::Blockchain::Error => e
    report_exception(e)
    raise BalanceLoadError
  end

  def case_sensitive?
    @adapter.features[:case_sensitive]
  end

  def supports_cash_addr_format?
    @adapter.features[:cash_addr_format]
  end

  def fetch_transaction(transaction)
    tx = Peatio::Transaction.new(currency_id: transaction.currency_id,
                                 hash: transaction.txid,
                                 to_address: transaction.rid,
                                 amount: transaction.amount)
    if @adapter.respond_to?(:fetch_transaction)
      @adapter.fetch_transaction(tx)
    else
      tx
    end
  end

  def process_block(block_number)
    block = @adapter.fetch_block!(block_number)
    deposits = filter_deposits(block)
    withdrawals = filter_withdrawals(block)
    # TODO: Process Transactions with `pending` status

    accepted_deposits = []
    ActiveRecord::Base.transaction do
      accepted_deposits = deposits.map(&method(:update_or_create_deposit)).compact
      withdrawals.each(&method(:update_withdrawal))
    end
    accepted_deposits.each(&:process!)
    block
  end

  # Resets current cached state.
  def reset!
    @latest_block_number = nil
  end

  def update_height(block_number)
    raise Error, "#{blockchain.name} height was reset." if blockchain.height != blockchain.reload.height

    # NOTE: We use update_column to not change updated_at timestamp
    # because we use it for detecting blockchain configuration changes see Workers::Daemon::Blockchain#run.
    blockchain.update_column(:height, block_number) if latest_block_number - block_number >= blockchain.min_confirmations
  end

  private

  def filter_deposits(block)
    addresses = PaymentAddress.where(wallet: Wallet.deposit.with_currency(@currencies),
                                     blockchain_key: @blockchain.key, address: block.transactions.map(&:to_address)).pluck(:address)
    block.select { |transaction| transaction.to_address.in?(addresses) }
  end

  def filter_withdrawals(block)
    # TODO: Process addresses in batch in case of huge number of confirming withdrawals.
    withdraw_txids = Withdraws::Coin.confirming.where(currency: @currencies,
                                                      blockchain_key: @blockchain.key).pluck(:txid)
    block.select { |transaction| transaction.hash.in?(withdraw_txids) }
  end

  def update_or_create_deposit(transaction)
    blockchain_currency = BlockchainCurrency.find_by(currency_id: transaction.currency_id,
                                                     blockchain_key: @blockchain.key)
    if transaction.amount < blockchain_currency.min_deposit_amount
      # Currently we just skip tiny deposits.
      Rails.logger.info do
        "Skipped deposit with txid: #{transaction.hash} with amount: #{transaction.hash}"\
        " to #{transaction.to_address} in block number #{transaction.block_number}"
      end
      return
    end

    # Fetch transaction from a blockchain that has `pending` status.
    transaction = adapter.fetch_transaction(transaction) if @adapter.respond_to?(:fetch_transaction) && transaction.status.pending?
    return unless transaction.status.success?

    address = PaymentAddress.find_by(wallet: Wallet.deposit_wallets(transaction.currency_id, @blockchain.key), address: transaction.to_address)
    return if address.blank?

    # Skip deposit tx if there is tx for deposit collection process
    # TODO: select only pending transactions
    tx_collect = Transaction.where(txid: transaction.hash, reference_type: 'Deposit')
    return if tx_collect.present?

    if transaction.from_addresses.blank? && adapter.respond_to?(:transaction_sources)
      transaction.from_addresses = adapter.transaction_sources(transaction)
    end

    deposit =
      Deposits::Coin.find_or_create_by!(
        currency_id: transaction.currency_id,
        txid: transaction.hash,
        txout: transaction.txout,
        blockchain_key: @blockchain.key
      ) do |d|
        d.address = transaction.to_address
        d.amount = transaction.amount
        d.member = address.member
        d.from_addresses = transaction.from_addresses
        d.block_number = transaction.block_number
      end

    deposit.update_column(:block_number, transaction.block_number) if deposit.block_number != transaction.block_number
    # Manually calculating deposit confirmations, because blockchain height is not updated yet.
    if latest_block_number - deposit.block_number >= @blockchain.min_confirmations && deposit.accept!
      deposit
    else
      nil
    end
  end

  def update_withdrawal(transaction)
    withdrawal =
      Withdraws::Coin.confirming
        .find_by(currency_id: transaction.currency_id, blockchain_key: @blockchain.key, txid: transaction.hash)

    # Skip non-existing in database withdrawals.
    if withdrawal.blank?
      Rails.logger.info { "Skipped withdrawal: #{transaction.hash}." }
      return
    end

    withdrawal.update_column(:block_number, transaction.block_number)

    # Fetch transaction from a blockchain that has `pending` status.
    transaction = adapter.fetch_transaction(transaction) if @adapter.respond_to?(:fetch_transaction) && transaction.status.pending?
    # Manually calculating withdrawal confirmations, because blockchain height is not updated yet.
    if transaction.status.failed?
      withdrawal.fail!
    elsif transaction.status.success? && latest_block_number - withdrawal.block_number >= @blockchain.min_confirmations
      withdrawal.success!
    end
  end
end
