# encoding: UTF-8
# frozen_string_literal: true
module BlockchainService
  class Ripple < Base
    def process_blockchain(blocks_limit: 300, force: false)
      if blockchain.height > 0
        current_ledger   = blockchain.height
        latest_ledger    = [client.latest_block_number, current_ledger + blocks_limit].min
      else
        latest_ledger = client.latest_block_number
        current_ledger = latest_ledger
      end

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_ledger && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_ledger: #{latest_ledger}" }
        return
      end

      (current_ledger..latest_ledger).each do |ledger_index|
        Rails.logger.info { "Started processing #{blockchain.key} ledger #{ledger_index}." }

        transactions = client.fetch_transactions(ledger_index)
        next if transactions.blank?

        block_data = { id: ledger_index }
        block_data[:deposits]    = build_deposits(transactions, ledger_index)
        block_data[:withdrawals] = build_withdrawals(transactions, ledger_index)

        save_block(block_data, latest_ledger)

        Rails.logger.info { "Finished processing #{blockchain.key} ledger #{ledger_index}." }
      end
    rescue => e
      report_exception(e)
      Rails.logger.info { "Exception was raised during block processing." }
    end

    private

    def build_deposits(transactions, ledger_index)
      transactions.each_with_object([]) do |tx, deposits|
        next unless valid_transaction?(tx)

        destination_tag = tx['DestinationTag'] || client.destination_tag_from(tx['Destination'])
        address = "#{client.to_address(tx)}?dt=#{destination_tag}"

        payment_addresses_where(address: address) do |payment_address|
          deposit_txs = client.build_transaction(tx: tx, currency: payment_address.currency)
          deposit_txs.fetch(:entries).each_with_index do |entry, index|
            deposits << {
              txid:           deposit_txs[:id],
              address:        address,
              amount:         entry[:amount],
              member:         payment_address.account.member,
              currency:       payment_address.currency,
              txout:          index,
              block_number:   ledger_index
            }
          end
        end
      end
    end

    def build_withdrawals(transactions, ledger_index)
      transactions.each_with_object([]) do |tx, withdrawals|
        next unless valid_transaction?(tx)

        Withdraws::Coin
          .where(currency: currencies)
          .where(txid: client.normalize_txid(tx.fetch('hash')))
          .each do |withdraw|
            withdraw_txs = client.build_transaction(tx: tx,
                                                    currency: withdraw.currency)
            withdraw_txs.fetch(:entries).each do |entry|
              withdrawals << {
                txid:           withdraw_txs[:id],
                rid:            client.to_address(tx),
                amount:         entry[:amount],
                block_number:   ledger_index
              }
          end
        end
      end
    end

    def valid_transaction?(tx)
      client.inspect_address!(tx['Account'])[:is_valid] &&
        tx['TransactionType'].to_s == 'Payment' &&
        tx.dig('metaData', 'TransactionResult').to_s == 'tesSUCCESS' &&
        String === tx['Amount']
    end
  end
end
