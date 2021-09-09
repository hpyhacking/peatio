# frozen_string_literal: true

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
      filter_deposit_txs(block)
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

  def filter_deposit_txs(block)
    # Select pending transactions related to the platform
    deposit_txs = Transaction.where(reference_type: 'Deposit', txid: block.transactions.map(&:hash), status: :pending)
    # Deposit in state fee_collecting
    # check tx state
    # if succeed change state to fee_collected and change state of tx to succeed

    # Deposit in state fee_collected
    # There is no Transaction yet
    # no actions

    # Deposit in state collecting
    # check tx state
    # if succeed change state to collected and change state of tx to succeed
    deposit_txs.each do |tx|
      # Fetch Deposit record
      deposit = tx.reference

      # Skip already processed deposit (should not happen if transaction in pending state)
      next unless deposit.fee_collecting? || deposit.collecting?

      # Select tx from block
      block_tx = block.transactions.find { |blck_tx| tx if tx.txid == blck_tx.hash }
      block_tx = adapter.fetch_transaction(block_tx) if @adapter.respond_to?(:fetch_transaction) && (block_tx.status.pending? || block_tx.fee.blank?)

      # Update fee that was paid after execution
      tx.update!(fee: block_tx.fee, block_number: block_tx.block_number, fee_currency_id: block_tx.fee_currency_id )

      if block_tx.status.success?
        # If Deposit in fee_collecting state and Transaction for prepare deposit
        # change state to `fee_collected`
        if deposit.fee_collecting? && tx.kind == 'tx_prebuild'
          deposit.confirm_fee_collection!
          tx.confirm!
        end
        # If Deposit in collecting state and Transaction for deposit collection
        # change state to `collected`
        if deposit.collecting? && tx.kind == 'tx'
          updated_spread = deposit.spread.map do |spread_tx|
            spread_tx[:status] = 'succeed' if spread_tx[:hash] == block_tx.hash
            spread_tx
          end
          deposit.update(spread: updated_spread)
          deposit.dispatch! if deposit.spread.map { |t| t[:status].in?(%w[skipped succeed]) }.all?(true)
          tx.confirm!
        end
      elsif block_tx.status.failed?
        deposit.err! StandardError.new 'Fee collection transaction failed' if tx.kind == 'tx_prebuild'
        deposit.err! StandardError.new 'Collection transaction failed' if tx.kind == 'tx'
        tx.fail!
      else
        Rails.logger.info { "Skipped deposit #{deposit.inspect} and transaction #{block_tx.inspect}" }
      end
    end
  end

  def filter_withdrawals(block)
    # TODO: Process addresses in batch in case of huge number of confirming withdrawals.
    withdraw_txids = Withdraws::Coin.confirming.where(currency: @currencies,
                                                      blockchain_key: @blockchain.key).pluck(:txid)
    block.select { |transaction| transaction.hash.in?(withdraw_txids) }
  end

  def update_or_create_deposit(transaction)
    blockchain_currency = BlockchainCurrency.find_network(@blockchain.key, transaction.currency_id)

    # Transaction amount will be blank in case of failed trasanctions
    # System'll update deposit on filter_deposit_txs then
    return if transaction.amount.blank?

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

    db_tx = Transaction.find_by(txid: transaction.hash)
    db_tx.update!(fee: transaction.fee, block_number: transaction.block_number, fee_currency_id: transaction.fee_currency_id)

    # Manually calculating withdrawal confirmations, because blockchain height is not updated yet.
    if transaction.status.failed?
      withdrawal.fail!
      db_tx.fail!
    elsif transaction.status.success? && latest_block_number - withdrawal.block_number >= @blockchain.min_confirmations
      withdrawal.success!
      db_tx.confirm!
    end
  end
end
