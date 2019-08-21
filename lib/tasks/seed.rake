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

  desc 'Adds missing currencies to database defined at config/seed/currencies.yml.'
  task currencies: :environment do
    Currency.transaction do
      YAML.load_file(Rails.root.join('config/seed/currencies.yml')).each do |hash|
        next if Currency.exists?(id: hash.fetch('id'))
        Currency.create!(hash)
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

  desc 'Adds missing markets to database defined at config/seed/markets.yml.'
  task markets: :environment do
    Market.transaction do
      YAML.load_file(Rails.root.join('config/seed/markets.yml'))
        .map(&:symbolize_keys)
        .each do |hash|
          next if Market.exists?(id: hash.fetch(:id))
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
          Market.create!(hash)
        end
    end
  end

  desc 'Adds missing wallets to database defined at config/seed/wallets.yml.'
  task wallets: :environment do
    Wallet.transaction do
      YAML.load_file(Rails.root.join('config/seed/wallets.yml')).each do |hash|
        next if Wallet.exists?(name: hash.fetch('name'))
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
end
