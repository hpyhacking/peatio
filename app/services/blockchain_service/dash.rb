# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Dash < Bitcoin

    private

    def build_deposits(block_json, block_id)
      block_json
        .fetch('tx')
        .each_with_object([]) do |tx, deposits|

        # get raw transaction
        txn = client.get_raw_transaction(tx)

        payment_addresses_where(address: client.to_address(txn)) do |payment_address|
          # If payment address currency doesn't match with blockchain

          deposit_txs = client.build_transaction(txn, block_id, payment_address.address)

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
            .where(txid: client.normalize_txid(tx))
            .each do |withdraw|
            # If wallet currency doesn't match with blockchain transaction

            # get raw transaction
            txn = client.get_raw_transaction(tx)

            withdraw_txs = client.build_transaction(txn, block_id, withdraw.rid)
            withdraw_txs.fetch(:entries).each do |entry|
              withdrawals << {  txid:           withdraw_txs[:id],
                                rid:            entry[:address],
                                amount:         entry[:amount],
                                block_number:   withdraw_txs[:block_number] }
            end
          end
      end
    end

  end
end

