# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Bitcoin < Base
    # Rough number of blocks per hour for Bitcoin is 6.
    def process_blockchain(blocks_limit: 6, force: false)
      latest_block = client.latest_block_number

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_block && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_block: #{latest_block}" }
        fetch_unconfirmed_deposits
        return
      end

      from_block   = blockchain.height || 0
      to_block     = [latest_block, from_block + blocks_limit].min

      (from_block..to_block).each do |block_id|
        Rails.logger.info { "Started processing #{blockchain.key} block number #{block_id}." }

        block_hash = client.get_block_hash(block_id)
        next if block_hash.blank?

        block_json = client.get_block(block_hash)
        next if block_json.blank? || block_json['tx'].blank?

        block_data = { id: block_id }
        block_data[:deposits]    = build_deposits(block_json, block_id)
        block_data[:withdrawals] = build_withdrawals(block_json, block_id)

        save_block(block_data, latest_block)

        Rails.logger.info { "Finished processing #{blockchain.key} block number #{block_id}." }
      end
    rescue => e
      report_exception(e)
      Rails.logger.info { "Exception was raised during block processing." }
    end

    private

    def build_deposits(block_json, block_id)
      block_json
        .fetch('tx')
        .each_with_object([]) do |tx, deposits|

        payment_addresses_where(address: client.to_address(tx)) do |payment_address|
          # If payment address currency doesn't match with blockchain

          deposit_txs = client.build_transaction(tx, block_id, payment_address.address)

          deposit_txs.fetch(:entries).each_with_index do |entry, i|
            deposits << { txid:           deposit_txs[:id],
                          address:        entry[:address],
                          amount:         entry[:amount],
                          member:         payment_address.account.member,
                          currency:       payment_address.currency,
                          txout:          i,
                          block_number:   deposit_txs[:block_number] }
          end
        end
      end
    end

    def build_withdrawals(block_json, block_id)
      block_json
        .fetch('tx')
        .each_with_object([]) do |tx, withdrawals|

        Withdraws::Coin
          .where(currency: currencies)
          .where(txid: client.normalize_txid(tx.fetch('txid')))
          .each do |withdraw|
          # If wallet currency doesn't match with blockchain transaction

          withdraw_txs = client.build_transaction(tx, block_id, withdraw.rid)
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawals << {  txid:           withdraw_txs[:id],
                              rid:            entry[:address],
                              amount:         entry[:amount],
                              block_number:   withdraw_txs[:block_number] }
          end
        end
      end
    end

    def fetch_unconfirmed_deposits(block_json = {})
      Rails.logger.info { "Processing unconfirmed deposits." }
      txns = client.get_unconfirmed_txns

      # Read processed mempool tx ids because we can skip them.
      processed = Rails.cache.read("processed_#{self.class.name.underscore}_mempool_txids") || []

      # Skip processed txs.
      block_json.merge!('tx' => txns - processed)
      deposits = build_deposits(block_json, nil)
      update_or_create_deposits!(deposits)

      # Store processed tx ids from mempool.
      Rails.cache.write("processed_#{self.class.name.underscore}_mempool_txids", txns)
    end
  end
end

