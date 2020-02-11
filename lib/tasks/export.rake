# frozen_string_literal: true

require 'yaml'

namespace :export do
  desc 'Export all configs to yaml files.'
  task configs: :environment do
    Rake::Task['export:blockchains'].invoke
    Rake::Task['export:currencies'].invoke
    Rake::Task['export:markets'].invoke
    Rake::Task['export:wallets'].invoke
    Rake::Task['export:trading_fees'].invoke
  end

  desc 'Export blockchains config to yaml file.'
  task blockchains: :environment do
    result = export('Blockchain')

    result.map! { |r| r.except!('id') }
    File.open('config/seed/blockchains_backup.yml', 'w') do |file|
      file.write result.to_yaml
    end
  end

  desc 'Export currencies config to yaml file.'
  task currencies: :environment do
    result = export('Currency')

    result.each { |c| c['options'] = c['options'].to_h }

    File.open('config/seed/currencies_backup.yml', 'w') do |file|
      file.write result.to_yaml
    end
  end

  desc 'Export markets config to yaml file.'
  task markets: :environment do
    result = export('Market')

    File.open('config/seed/markets_backup.yml', 'w') do |file|
      file.write result.to_yaml
    end
  end

  desc 'Export wallets config to yaml file.'
  task wallets: :environment do
    result = export('Wallet')

    result.map! { |r| r.except!('id') }
    File.open('config/seed/wallets_backup.yml', 'w') do |file|
      file.write result.to_yaml
    end
  end

  desc 'Export trading fees config to yaml file.'
  task trading_fees: :environment do
    result = export('TradingFee')

    result.map! { |r| r.except!('id') }
    File.open('config/seed/trading_fees_backup.yml', 'w') do |file|
      file.write result.to_yaml
    end
  end

  def export(model_name)
    model_name.constantize.all.map do |m|
      m.attributes.except('settings_encrypted', 'created_at', 'updated_at').merge('settings' => m.try(:settings))
    end.map { |r| r.transform_values! { |v| v.is_a?(BigDecimal) ? v.to_f : v } }.map(&:compact)
  end
end
