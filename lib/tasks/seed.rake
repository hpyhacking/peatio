# encoding: UTF-8
# frozen_string_literal: true
require 'yaml'

namespace :seed do
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
      YAML.load_file(Rails.root.join('config/seed/markets.yml')).each do |hash|
        next if Market.exists?(id: hash.fetch('id'))
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
end
