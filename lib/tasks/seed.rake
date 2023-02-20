# encoding: UTF-8
# frozen_string_literal: true
require 'yaml'

namespace :seed do
  desc 'Adds missing accounts to database defined at config/seed/accounts.yml.'
  task accounts: :environment do
    Operations::Account.transaction do
      YAML.load_file(Rails.root.join('config/seed/accounts.yml')).each do |hash|
        next if Operations::Account.exists?(code: hash.fetch('code'))
        Operations::Account.create!(hash)
      end
    end
  end

  # TODO: Deprecate seed tasks in favour of import:configs
  desc 'Adds missing currencies to database defined at config/seed/currencies.yml.'
  task currencies: :environment do
    Currency.transaction do
      YAML.load_file(Rails.root.join('config/seed/currencies.yml')).each do |hash|

        next if Currency.exists?(id: hash.fetch('id'))
        Currency.create!(hash.except('networks'))

        if hash['networks'].present?
          BlockchainCurrency.transaction do
            hash['networks'].each do |network|
              next if BlockchainCurrency.exists?(currency_id: hash.fetch('id'), blockchain_key: network.fetch('blockchain_key'))
              BlockchainCurrency.create!(network.merge(currency_id: hash.fetch('id')))
            end
          end
        end
      end
    end
  end

  desc 'Adds missing blockchains to database defined at config/seed/blockchains.yml.'
  task blockchains: :environment do
    Blockchain.transaction do
      YAML.load_file(Rails.root.join('config/seed/blockchains.yml')).each do |hash|
        next if Blockchain.exists?(key: hash.fetch('key'))
        Blockchain.create!(hash)
      end
    end
  end

  desc 'Adds missing engines to database defined at config/seed/engines.yml.'
  task engines: :environment do
    Engine.transaction do
      YAML.load_file(Rails.root.join('config/seed/engines.yml')).each do |hash|
        next if Engine.exists?(name: hash.fetch('name'))
        Engine.create!(hash)
      end
    end
  end

  desc 'Adds missing markets to database defined at config/seed/markets.yml.'
  task markets: :environment do
    Market.transaction do
      YAML.load_file(Rails.root.join('config/seed/markets.yml'))
        .map(&:symbolize_keys)
        .each do |hash|
          next if Market.exists?(symbol: hash.fetch(:symbol))
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
          engine = Engine.find_by(name: hash[:engine_name])
          if engine.present?
            hash.delete :engine_name
            hash[:engine_id] = engine.id
            Market.create!(hash)
          else
            Rails.logger.error "Engine doesn't exist"
          end
        end
    end
  end

  desc 'Adds missing wallets to database defined at config/seed/wallets.yml.'
  task wallets: :environment do
    Wallet.transaction do
      YAML.load_file(Rails.root.join('config/seed/wallets.yml')).each do |hash|
        next if Wallet.exists?(name: hash.fetch('name'))
        if hash['currency_ids'].is_a?(String)
          hash['currency_ids'] = hash['currency_ids'].split(',')
        end
        Wallet.create!(hash)
      end
    end
  end

  desc 'Adds missing trading_fees to database defined at config/seed/trading_fees.yml.'
  task trading_fees: :environment do
    TradingFee.transaction do
      YAML.load_file(Rails.root.join('config/seed/trading_fees.yml')).each do |hash|
        next if TradingFee.exists?(market_id: hash.fetch('market_id'), group: hash.fetch('group'))
        TradingFee.create!(hash)
      end
    end
  end

  desc 'Adds missing whitelisted_smart_contracts to database defined at config/seed/whitelisted_smart_contracts.yml.'
  task whitelisted_smart_contracts: :environment do
    WhitelistedSmartContract.transaction do
      YAML.load_file(Rails.root.join('config/seed/whitelisted_smart_contracts.yml')).each do |hash|
        next if WhitelistedSmartContract.exists?(address: hash.fetch('address'), blockchain_key: hash.fetch('blockchain_key'))
        next if Blockchain.find_by(key: hash.fetch('blockchain_key')).blank?

        WhitelistedSmartContract.create!(hash)
      end
    end
  end
end
