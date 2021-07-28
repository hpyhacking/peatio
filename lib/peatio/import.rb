# encoding: UTF-8
# frozen_string_literal: true

module Peatio
  class Import
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def load_all
      load_accounts
      load_blockchains
      load_currencies
      load_wallets
      load_engines
      load_markets
      load_trading_fees
      load_whitelisted_smart_contracts
    end

    def load_accounts
      return unless @data.include? 'accounts'

      Kernel.puts 'Importing accounts'
      ::Operations::Account.transaction do
        @data['accounts'].each do |hash|
          next if ::Operations::Account.exists?(code: hash.fetch('code'))

          ::Operations::Account.create!(hash)
          Kernel.puts "Created #{hash.fetch('code')} account"
        end
      end
    end

    def load_blockchains
      return unless @data.include? 'blockchains'

      Kernel.puts 'Importing blockchains'
      ::Blockchain.transaction do
        @data['blockchains'].each do |hash|
          next if ::Blockchain.exists?(key: hash.fetch('key'))

          ::Blockchain.create!(hash)
          Kernel.puts "Created #{hash.fetch('key')} blockchain"
        end
      end
    end

    def load_currencies
      return unless @data.include? 'currencies'

      Kernel.puts 'Importing currencies'
      ::Currency.transaction do
        @data['currencies'].each do |hash|
          next if ::Currency.exists?(id: hash.fetch('id'))

          ::Currency.create!(hash)
          Kernel.puts "Created #{hash.fetch('id')} currency"

          if hash['networks'].present?
            ::BlockchainCurrency.transaction do
              hash['networks'].each do |network|
                next if BlockchainCurrency.exists?(currency_id: hash.fetch('id'), blockchain_key: network.fetch('blockchain_key'))
                
                BlockchainCurrency.create!(network.merge(currency_id: hash.fetch('id')))
                Kernel.puts "Created blockchain currency with currency_id #{hash.fetch('id')} and #{network.fetch('blockchain_key')} blockchain"
              end
            end
          end
        end
      end
    end

    def load_wallets
      return unless @data.include? 'wallets'

      Kernel.puts 'Importing wallets'
      ::Wallet.transaction do
        @data['wallets'].each do |hash|
          next if ::Wallet.exists?(name: hash.fetch('name'))

          if hash['currency_ids'].is_a?(String)
            hash['currency_ids'] = hash['currency_ids'].split(',')
          end

          ::Wallet.create!(hash)

          Kernel.puts "Created #{hash.fetch('name')} wallet"
        end
      end
    end

    def load_whitelisted_smart_contracts
      return unless @data.include? 'whitelisted_smart_contracts'

      Kernel.puts 'Importing whitelisted_smart_contracts'
      ::Wallet.transaction do
        @data['whitelisted_smart_contracts'].each do |hash|
          next if ::WhitelistedSmartContract.exists?(address: hash.fetch('address'), blockchain_key: hash.fetch('blockchain_key'))

          ::WhitelistedSmartContract.create!(hash)

          Kernel.puts "Created #{hash.fetch('address')}, #{hash.fetch('blockchain_key')} whitelisted_smart_contracts"
        end
      end
    end

    def load_trading_fees
      return unless @data.include? 'trading_fees'

      Kernel.puts 'Importing trading_fees'
      ::TradingFee.transaction do
        @data['trading_fees'].each do |hash|
          next if ::TradingFee.exists?(market_id: hash.fetch('market_id'), group: hash.fetch('group'))

          ::TradingFee.create!(hash)
          Kernel.puts "Created [#{hash.fetch('market_id')}, #{hash.fetch('group')}] trading fees"
        end
      end
    end

    def load_engines
      return unless @data.include? 'engines'

      Kernel.puts 'Importing engines'
      ::Engine.transaction do
        @data['engines'].each do |hash|
          next if ::Engine.exists?(name: hash.fetch('name'))

          ::Engine.create!(hash)
          Kernel.puts "Created #{hash.fetch('name')} engine"
        end
      end
    end

    def load_markets
      return unless @data.include? 'markets'

      Kernel.puts 'Importing markets'
      ::Market.transaction do
        @data['markets'].map(&:symbolize_keys).each do |hash|
          next if ::Market.exists?(symbol: hash.fetch(:symbol))

          # For compatibility with old markets.yml
          # If state is not defined set it from enabled.
          enabled = hash.delete(:enabled)
          hash[:state] ||= enabled ? :enabled : :disabled

          # For compatibility with old markets.yml we keep legacy-new keys mapping.
          # New key value has higher priority than legacy.
          legacy_keys_mappings = { ask_unit:       :base_unit,
                                   bid_unit:       :quote_unit,
                                   ask_precision:  :amount_precision,
                                   bid_precision:  :price_precision,
                                   min_ask_price:  :min_price,
                                   max_bid_price:  :max_price,
                                   min_ask_amount: :min_amount,
                                   min_bid_amount: :min_amount }

          legacy_keys_mappings.each do |old_key, new_key|
            legacy_key_value = hash.delete(old_key)
            hash[new_key] ||= legacy_key_value
          end

          # Select engine with provided name
          engine = ::Engine.find_by(name: hash[:engine_name])
          if engine.present?
            hash.delete :engine_name
            hash[:engine_id] = engine.id
            ::Market.create!(hash)
          else
            Kernel.puts "Engine #{hash[:engine_name]} doesn't exist"
          end
        end
      end
    end
  end
end
