module Bitcoin
  # TODO: Processing of unconfirmed transactions from mempool isn't supported now.
  class Blockchain < Peatio::Blockchain::Abstract

    DEFAULT_FEATURES = {case_sensitive: true, cash_addr_format: false}.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil
      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))
    end

    def fetch_block!(block_number)
      block_hash = client.json_rpc(:getblockhash, [block_number])

      client.json_rpc(:getblock, [block_hash, 2])
        .fetch('tx').each_with_object([]) do |tx, txs_array|
          txs = build_transaction(tx).map do |ntx|
            Peatio::Transaction.new(ntx.merge(block_number: block_number))
          end
          txs_array.append(*txs)
        end.yield_self { |txs_array| Peatio::Block.new(block_number, txs_array) }
    rescue Bitcoin::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def latest_block_number
      client.json_rpc(:getblockcount)
    rescue Bitcoin::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def fetch_transaction(transaction)
      transaction_hash = client.json_rpc(:getrawtransaction, [transaction.hash, 1])
      tx = nil
      transaction_hash.fetch('vout').select do |entry|
        entry.fetch('value').to_d > 0 &&
        entry['scriptPubKey'].has_key?('addresses')
      end.each do |entry|
        if transaction.to_address == entry['scriptPubKey']['addresses'][0] && entry.fetch('value').to_d == transaction.amount
          tx = { hash: transaction_hash['txid'], txout: entry['n'],
                 to_address: entry['scriptPubKey']['addresses'][0],
                 amount: entry.fetch('value').to_d,
                 status: 'success' }
          break
        else
          next
        end
      end
      if tx.present?
        Peatio::Transaction.new(tx)
      else
        Peatio::Transaction.new
      end
    end

    def transaction_sources(transaction)
      transaction_hash = client.json_rpc(:getrawtransaction, [transaction.hash, 1])
      transaction_hash['vin'].each_with_object([]) do |vin, source_addresses|
        next if vin['txid'].blank?

        vin_transaction = client.json_rpc(:getrawtransaction, [vin['txid'], 1])
        source = vin_transaction['vout'].find { |hash| hash['n'] == vin['vout'] }
        source_addresses << source['scriptPubKey']['addresses'][0]
      end.compact.uniq
    end

    def load_balance_of_address!(address, _currency_id)
      address_with_balance = client.json_rpc(:listaddressgroupings)
                                   .flatten(1)
                                   .find { |addr| addr[0] == address }

      if address_with_balance.blank?
        raise Peatio::Blockchain::UnavailableAddressBalanceError, address
      end

      address_with_balance[1].to_d
    rescue Bitcoin::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    private

    def build_transaction(tx_hash)
      tx_hash.fetch('vout')
        .select do |entry|
          entry.fetch('value').to_d > 0 &&
          entry['scriptPubKey'].has_key?('addresses')
        end
        .each_with_object([]) do |entry, formatted_txs|
          no_currency_tx =
            { hash: tx_hash['txid'], txout: entry['n'],
              to_address: entry['scriptPubKey']['addresses'][0],
              amount: entry.fetch('value').to_d,
              status: 'success' }

            # Build transaction for each currency belonging to blockchain.
            settings_fetch(:currencies).pluck(:id).each do |currency_id|
              formatted_txs << no_currency_tx.merge(currency_id: currency_id)
            end
        end
    end

    def client
      @client ||= Bitcoin::Client.new(settings_fetch(:server))
    end

    def settings_fetch(key)
      @settings.fetch(key) { raise Peatio::Blockchain::MissingSettingError, key.to_s }
    end
  end
end
