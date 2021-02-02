module Ethereum
  class Blockchain < Peatio::Blockchain::Abstract

    UndefinedCurrencyError = Class.new(StandardError)

    TOKEN_EVENT_IDENTIFIER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    SUCCESS = '0x1'
    FAILED = '0x0'

    DEFAULT_FEATURES = { case_sensitive: false, cash_addr_format: false }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil
      @erc20 = []; @eth = []
      @whitelisted_addresses = if settings[:whitelisted_addresses].present?
                                 settings[:whitelisted_addresses].pluck(:address).to_set
                               else
                                 []
                               end

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))
      @settings[:currencies]&.each do |c|
        if c.dig(:options, :erc20_contract_address).present?
          @erc20 << c
        else
          @eth << c
        end
      end
    end

    def fetch_block!(block_number)
      block_json = client.json_rpc(:eth_getBlockByNumber, ["0x#{block_number.to_s(16)}", true])

      if block_json.blank? || block_json['transactions'].blank?
        return Peatio::Block.new(block_number, [])
      end
      block_json.fetch('transactions').each_with_object([]) do |tx, block_arr|
        if tx.fetch('input').hex <= 0
          next if invalid_eth_transaction?(tx)
        else
          next if @erc20.find do |c|
            # Check `to` and `input` options to find erc-20 smart contract contract 
            c.dig(:options, :erc20_contract_address) == normalize_address(tx.fetch('to')) ||
            c.dig(:options, :erc20_contract_address) == '0x' + tx.fetch('input')[34...74].to_s ||
            # Check if `to` in whitelisted smart contracts
            @whitelisted_addresses.include?(tx.fetch('to'))
          end.blank?

          tx = client.json_rpc(:eth_getTransactionReceipt, [normalize_txid(tx.fetch('hash'))])
          next if tx.nil? || tx.fetch('to').blank?
        end

        txs = build_transactions(tx).map do |ntx|
          Peatio::Transaction.new(ntx)
        end

        block_arr.append(*txs)
      end.yield_self { |block_arr| Peatio::Block.new(block_number, block_arr) }
    rescue Ethereum::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def latest_block_number
      client.json_rpc(:eth_blockNumber).to_i(16)
    rescue Ethereum::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def load_balance_of_address!(address, currency_id)
      currency = settings[:currencies].find { |c| c[:id] == currency_id.to_s }
      raise UndefinedCurrencyError unless currency

      if currency.dig(:options, :erc20_contract_address).present?
        load_erc20_balance(address, currency)
      else
        client.json_rpc(:eth_getBalance, [normalize_address(address), 'latest'])
              .hex
              .to_d
              .yield_self { |amount| convert_from_base_unit(amount, currency) }
      end
    rescue Ethereum::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def fetch_transaction(transaction)
      currency = settings[:currencies].find { |c| c.fetch(:id) == transaction.currency_id }
      return if currency.blank?
      txn_receipt = client.json_rpc(:eth_getTransactionReceipt, [transaction.hash])
      if currency.in?(@eth)
        txn_json = client.json_rpc(:eth_getTransactionByHash, [transaction.hash])
        attributes = {
          amount: convert_from_base_unit(txn_json.fetch('value').hex, currency),
          to_address: normalize_address(txn_json['to']),
          txout: txn_json.fetch('transactionIndex').to_i(16),
          status: transaction_status(txn_receipt)
        }
      else
        if transaction.txout.present?
          txn_json = txn_receipt.fetch('logs').find { |log| log['logIndex'].to_i(16) == transaction.txout }
        else
          txn_json = txn_receipt.fetch('logs').first
        end
        attributes = {
          amount: convert_from_base_unit(txn_json.fetch('data').hex, currency),
          to_address: normalize_address('0x' + txn_json.fetch('topics').last[-40..-1]),
          status: transaction_status(txn_receipt)
        }
      end
      transaction.assign_attributes(attributes)
      transaction
    end

    private

    def load_erc20_balance(address, currency)
      data = abi_encode('balanceOf(address)', normalize_address(address))
      client.json_rpc(:eth_call, [{ to: contract_address(currency), data: data }, 'latest'])
            .hex
            .to_d
            .yield_self { |amount| convert_from_base_unit(amount, currency) }
    end

    def client
      @client ||= Ethereum::Client.new(settings_fetch(:server))
    end

    def settings_fetch(key)
      @settings.fetch(key) { raise Peatio::Blockchain::MissingSettingError, key.to_s }
    end

    def normalize_txid(txid)
      txid.try(:downcase)
    end

    def normalize_address(address)
      address.try(:downcase)
    end

    def build_transactions(tx_hash)
      if tx_hash.has_key?('logs')
        build_erc20_transactions(tx_hash)
      else
        build_eth_transactions(tx_hash)
      end
    end

    def build_eth_transactions(block_txn)
      @eth.map do |currency|
        { hash:           normalize_txid(block_txn.fetch('hash')),
          amount:         convert_from_base_unit(block_txn.fetch('value').hex, currency),
          from_addresses: [normalize_address(block_txn['from'])],
          to_address:     normalize_address(block_txn['to']),
          txout:          block_txn.fetch('transactionIndex').to_i(16),
          block_number:   block_txn.fetch('blockNumber').to_i(16),
          currency_id:    currency.fetch(:id),
          status:         transaction_status(block_txn) }
      end
    end

    def build_erc20_transactions(txn_receipt)
      # Build invalid transaction for failed withdrawals
      if transaction_status(txn_receipt) == 'fail' && txn_receipt.fetch('logs').blank?
        return build_invalid_erc20_transaction(txn_receipt)
      end

      txn_receipt.fetch('logs').each_with_object([]) do |log, formatted_txs|

        next if log['blockHash'].blank? && log['blockNumber'].blank?
        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER

        # Skip if ERC20 contract address doesn't match.
        currencies = @erc20.select { |c| c.dig(:options, :erc20_contract_address) == log.fetch('address') }
        next if currencies.blank?

        destination_address = normalize_address('0x' + log.fetch('topics').last[-40..-1])

        currencies.each do |currency|
          formatted_txs << { hash:            normalize_txid(txn_receipt.fetch('transactionHash')),
                             amount:          convert_from_base_unit(log.fetch('data').hex, currency),
                             from_addresses:  [normalize_address(txn_receipt['from'])],
                             to_address:      destination_address,
                             txout:           log['logIndex'].to_i(16),
                             block_number:    txn_receipt.fetch('blockNumber').to_i(16),
                             currency_id:     currency.fetch(:id),
                             status:          transaction_status(txn_receipt) }
        end
      end
    end

    def build_invalid_erc20_transaction(txn_receipt)
      currencies = @erc20.select { |c| c.dig(:options, :erc20_contract_address) == txn_receipt.fetch('to') }
      return if currencies.blank?

      currencies.each_with_object([]) do |currency, invalid_txs|
        invalid_txs << { hash:         normalize_txid(txn_receipt.fetch('transactionHash')),
                         block_number: txn_receipt.fetch('blockNumber').to_i(16),
                         currency_id:  currency.fetch(:id),
                         status:       transaction_status(txn_receipt) }
      end
    end

    def transaction_status(block_txn)
      if block_txn.dig('status') == SUCCESS
        'success'
      elsif block_txn.dig('status') == FAILED
        'failed'
      else
        'pending'
      end
    end

    def invalid_eth_transaction?(block_txn)
      block_txn.fetch('to').blank? \
      || block_txn.fetch('value').hex.to_d <= 0 && block_txn.fetch('input').hex <= 0
    end

    def contract_address(currency)
      normalize_address(currency.dig(:options, :erc20_contract_address))
    end

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def convert_from_base_unit(value, currency)
      value.to_d / currency.fetch(:base_factor).to_d
    end
  end
end
