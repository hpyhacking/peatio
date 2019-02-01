# encoding: UTF-8
# frozen_string_literal: true

class BlockchainService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns Service for given blockchain key.
    #
    # @param key [String, Symbol]
    #   The blockchain key.
    def [](key)
      blockchain = Blockchain.find_by_key(key)
      BlockchainService.new(blockchain)
    end
  end

  attr_reader :blockchain

  def initialize(blockchain)
    @blockchain = blockchain
    @service =
        "Peatio::BlockchainService::#{blockchain.client.capitalize}"
          .constantize
          .new(logger: Rails.logger.info, cache: Rails.cache,
               blockchain: blockchain, currencies: blockchain.currencies)
    # TODO: Raise Peatio::Blockchain::Error unless class exist.
  end

  def process_blockchain(blocks_limit: 250, force: false)
    # Don't start process if we didn't receive new blocks.
    latest_block = @service.latest_block
    if @blockchain.height + @blockchain.min_confirmations >= latest_block && !force
      Rails.logger.info { "Skip synchronization. No new blocks detected height: #{@blockchain.height}, latest_block: #{latest_block}" }
      return
    end

    from_block = @blockchain.height
    to_block = [latest_block, from_block + blocks_limit]. min
    # binding.pry
    from_block.upto(to_block) do |block_number|
      process_block(block_number)
    end
    # TODO: Tricky!!!
    update_height if @service.current_block
  # rescue => e
  #   report_exception(e)
  #   Rails.logger.info { "Exception was raised during block processing." }
  end

  # TODO: Rename method.
  def process_block(block_number)
    @service.fetch_block!(block_number)

    addresses = PaymentAddress.where(currency: @blockchain.currencies)
    withdrawals = Withdraws::Coin.confirming.where(currency: @blockchain.currencies)

    ActiveRecord::Base.transaction do
      # binding.pry
      pp "withdrawals=#{withdrawals.count}"
      pp block_number, @service.filtered_withdrawals(withdrawals)
      @service.filtered_deposits(addresses, &method(:update_or_create_deposit!))
      @service.filtered_withdrawals(withdrawals, &method(:update_withdrawal!))
    end
  end

  def update_or_create_deposit!(deposit_hash)
    # If deposit doesn't exist create it.
    deposit = Deposits::Coin
                .where(currency: @blockchain.currencies)
                .find_or_create_by!(deposit_hash.slice(:txid, :txout)) do |deposit|
      deposit.assign_attributes(deposit_hash)
    end

    deposit.update_column(:block_number, deposit_hash.fetch(:block_number))
    if deposit.confirmations >= blockchain.min_confirmations
      deposit.collect! if deposit.accept!
    end
  end

  def update_withdrawal!(withdrawal_hash)
    withdrawal = Withdraws::Coin
                   .confirming
                   .where(currency: @blockchain.currencies)
                   .find_by(withdrawal_hash.slice(:txid)) do |withdrawal|
      withdrawal.assign_attributes(withdrawal_hash)
    end

    # Skip non-existing in database withdrawals.
    if withdrawal.blank?
      Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
      return
    end

    withdrawal.update_column(:block_number, withdrawal_hash.fetch(:block_number))
    withdrawal.success! if withdrawal.confirmations >= blockchain.min_confirmations
  end

  def update_height
    raise Error, "#{@blockchain.name} height was reset." if @blockchain.height != @blockchain.reload.height
    if @service.latest_block - @service.current_block >= @blockchain.min_confirmations
      @blockchain.update(height: @service.current_block)
    end
  end
end
