class BlockchainService
  Error = Class.new(StandardError)
  BalanceLoadError = Class.new(StandardError)

  attr_reader :blockchain, :currencies, :adapter

  def initialize(blockchian)
    @blockchain = blockchian
    @currencies = blockchian.currencies.deposit_enabled
    @adapter = Peatio::Blockchain.registry[blockchian.client.to_sym]
    @adapter.configure(server: @blockchain.server,
                       currencies: @currencies.map(&:to_blockchain_api_settings))
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

  def process_block(block_number)
    block = @adapter.fetch_block!(block_number)
    deposits = filter_deposits(block)
    withdrawals = filter_withdrawals(block)

    accepted_deposits = []
    ActiveRecord::Base.transaction do
      accepted_deposits = deposits.map(&method(:update_or_create_deposit)).compact
      withdrawals.each(&method(:update_withdrawal))
      update_height(block_number)
    end
    accepted_deposits.each(&:collect!)
    block
  end

  # Resets current cached state.
  def reset!
    @latest_block_number = nil
  end

  private

  def filter_deposits(block)
    # TODO: Process addresses in batch in case of huge number of PA.
    addresses = PaymentAddress.where(currency: @currencies).pluck(:address).compact
    block.select { |transaction| transaction.to_address.in?(addresses) }
  end

  def filter_withdrawals(block)
    # TODO: Process addresses in batch in case of huge number of confirming withdrawals.
    withdraw_txids = Withdraws::Coin.confirming.where(currency: @currencies).pluck(:txid)
    block.select { |transaction| transaction.hash.in?(withdraw_txids) }
  end

  def update_or_create_deposit(transaction)
    if transaction.amount <= Currency.find(transaction.currency_id).min_deposit_amount
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

    # TODO: Rewrite this guard clause
    return unless PaymentAddress.exists?(currency_id: transaction.currency_id, address: transaction.to_address)

    deposit =
      Deposits::Coin.find_or_create_by!(
        currency_id: transaction.currency_id,
        txid: transaction.hash,
        txout: transaction.txout
      ) do |d|
        d.address = transaction.to_address
        d.amount = transaction.amount
        d.member = PaymentAddress.find_by(currency_id: transaction.currency_id, address: transaction.to_address).account.member
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
        .find_by(currency_id: transaction.currency_id, txid: transaction.hash)

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

  def update_height(block_number)
    raise Error, "#{blockchain.name} height was reset." if blockchain.height != blockchain.reload.height

    blockchain.update(height: block_number) if latest_block_number - block_number >= blockchain.min_confirmations
  end
end
