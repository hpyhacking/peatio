# frozen_string_literal: true

require 'yaml'
require 'csv'
require 'peatio/export'

namespace :export do
  desc 'Export all configs to yaml files.'
  task configs: :environment do
    Rake::Task['export:blockchains'].invoke
    Rake::Task['export:currencies'].invoke
    Rake::Task['export:markets'].invoke
    Rake::Task['export:wallets'].invoke
    Rake::Task['export:engines'].invoke
    Rake::Task['export:trading_fees'].invoke
  end

  desc 'Export blockchains config to yaml file.'
  task :blockchains, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/blockchains.yml')
    File.write(args.export_path, Peatio::Export.new.export_blockchains.to_yaml)
  end

  desc 'Export currencies config to yaml file.'
  task :currencies, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/currencies_backup.yml')
    File.write(args.export_path, Peatio::Export.new.export_currencies.to_yaml)
  end

  desc 'Export markets config to yaml file.'
  task :markets, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/markets_backup.yml')
    File.write(args.export_path, Peatio::Export.new.export_markets.to_yaml)
  end

  desc 'Export wallets config to yaml file.'
  task :wallets, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/wallets_backup.yml')
    File.write(args.export_path, Peatio::Export.new.export_wallets.to_yaml)
  end

  desc 'Export trading fees config to yaml file.'
  task :trading_fees, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/trading_fees_backup.yml')
    File.write(args.export_path, Peatio::Export.new.export_trading_fees.to_yaml)
  end

  desc 'Export engines to yaml file.'
  task :engines, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'config/seed/engines_backup.yml')
    File.write(args.export_path, Peatio::Export.new.export_engines.to_yaml)
  end

  desc 'Export all members to csv file.'
  task :users, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'exported_users.csv')
    count = 0
    errors_count = 0
    begin
      CSV.open(args.export_path, 'w') do |csv|
        csv << %w[uid email level role state]
        Member.find_each do |member|
          csv << [member.uid, member.email, member.level, member.role, member.state]
          count += 1
        end
      rescue StandardError => e
        message = { error: e.message, email: member.email, uid: member.uid }
        Rails.logger.error message
        errors_count += 1
      end
    end
    Kernel.puts "Exported #{count} members"
    Kernel.puts "Errored #{errors_count}"
  end

  desc 'Export accounts to csv file.'
  task :accounts, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'exported_accounts.csv')
    count = 0
    errors_count = 0
    begin
      CSV.open(args.export_path, 'w') do |csv|
        csv << %w[uid currency_id main_balance locked_balance]
        Account.find_each do |account|
          if account.balance.positive? || account.locked.positive?
            csv << [account.member.uid, account.currency_id, account.balance, account.locked]
            count += 1
          end
        end
      rescue StandardError => e
        message = { error: e.message, uid: account.member.uid, currency_id: account.currency_id }
        Rails.logger.error message
        errors_count += 1
      end
    end
    Kernel.puts "Exported #{count} accounts"
    Kernel.puts "Errored #{errors_count}"
  end

  desc 'Export addresses to csv file.'
  task :addresses, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'exported_addresses.csv')
    count = 0
    errors_count = 0
    begin
      CSV.open(args.export_path, 'w') do |csv|
        csv << %w[uid wallet_name address secret details]
        PaymentAddress.find_each do |address|
          wallet = Wallet.find(address.wallet_id)
          # We save wallet name instead of id because id can change after export/import migration
          csv << [address.member.uid, wallet.name, address.address, address.secret, address.details]
          count += 1
        rescue StandardError => e
          message = { error: e.message, uid: address.member.uid, wallet_name: address.wallet.name }
          Rails.logger.error message
          errors_count += 1
        end
      end
    end
    Kernel.puts "Exported #{count} addresses"
    Kernel.puts "Errored #{errors_count}"
  end

  desc 'Export configs(blockchains, currencies, wallets, markets, engines) from the database'
  task :configs, [:export_path] => [:environment] do |_, args|
    args.with_defaults(export_path: 'export_configs.yaml')
    ex = Peatio::Export.new
    File.write(args.export_path, {
      'accounts' => ex.export_accounts,
      'blockchains' => ex.export_blockchains,
      'currencies' => ex.export_currencies,
      'markets' => ex.export_markets,
      'wallets' => ex.export_wallets,
      'trading_fees' => ex.export_trading_fees,
      'engines' => ex.export_engines
    }.to_yaml)
  end
end
