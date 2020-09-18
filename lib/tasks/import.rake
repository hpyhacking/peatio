# frozen_string_literal: true

require 'csv'
require 'peatio/import'

namespace :import do
  # Detailed instruction https://github.com/rubykube/peatio/blob/master/docs/tasks/import.md
  # Required fields for import users:
  # - uid
  # - email
  #
  # Usage:
  # For import users: -> bundle exec rake import:users['file_name.csv']

  desc 'Load members from csv file.'
  task :users, [:config_load_path] => [:environment] do |_, args|
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    count = 0
    errors_count = 0
    CSV.parse(csv_table, headers: true, quote_empty: false).each do |row|
      row = row.to_h.compact.symbolize_keys!
      defaults = { level: 0, role: 'member', state: 'active' }
      permitted_attr = %i[uid email level role state]
      Member.create!(row.slice(*permitted_attr).reverse_merge(defaults))
      count += 1
    rescue StandardError => e
      message = { error: e.message, email: row[:email], uid: row[:uid] }
      Rails.logger.error message
      errors_count += 1
    end
    Kernel.puts "Created #{count} members"
    Kernel.puts "Errored #{errors_count}"
  end

  # Required fields for import accounts balances:
  # - uid
  # - currency_id
  #
  # Make sure that you create required currency
  # Usage:
  # For import account balances: -> bundle exec rake import:accounts['file_name.csv']

  desc 'Load accounts balances from csv file.'
  task :accounts, %i[config_load_path balance_check] => [:environment] do |_, args|
    args.with_defaults(:config_load_path => 'exported_accounts.csv', :balance_check => false)
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    count = 0
    errors_count = 0
    CSV.parse(csv_table, headers: true).each do |row|
      row = row.to_h.compact.symbolize_keys!
      uid = row[:uid]
      member = Member.find_by_uid!(uid)
      currency = Currency.find(row[:currency_id])
      account = Account.find_or_create_by!(member: member, currency: currency)
      main_balance = row[:main_balance].to_d
      locked_balance = row[:locked_balance].to_d
      next if args[:balance_check] == 'true' && main_balance <= 0 && locked_balance <= 0

      ActiveRecord::Base.transaction do
        Operations::Asset.credit!(currency: currency, amount: main_balance + locked_balance)
        Operations::Liability.credit!(kind: :main, currency: currency, member_id: member.id, amount: main_balance)
        Operations::Liability.credit!(kind: :locked, currency: currency, member_id: member.id, amount: locked_balance)
        account.update!(balance: main_balance, locked: locked_balance)
        count += 1
      end
    rescue StandardError => e
      message = { error: e.message, uid: row[:uid] }
      Rails.logger.error message
      errors_count += 1
    end
    Kernel.puts "Accounts created #{count}"
    Kernel.puts "Errored #{errors_count}"
  end

  desc 'Load addresses from csv file'
  task :addresses, [:config_load_path] => [:environment] do |_, args|
    args.with_defaults(:config_load_path => 'exported_addresses.csv')
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    count = 0
    errors_count = 0
    CSV.parse(csv_table, headers: true).each do |row|
      row = row.to_h.compact.symbolize_keys!
      uid = row[:uid]
      member = Member.find_by_uid!(uid)
      currency = Currency.find(row[:currency_id])
      account = member.get_account(currency)
      account.payment_addresses.create(currency: currency, address: row[:address], secret: row[:secret], details: row[:details])
      count += 1
    rescue StandardError => e
      message = { error: e.message, uid: row[:uid], currency_id: currency_id[:currency_id] }
      Rails.logger.error message
      errors_count += 1
    end
    Kernel.puts "Addresses created #{count}"
    Kernel.puts "Errored #{errors_count}"
  end

  desc 'Import configs(blockchains, currencies, wallets, markets, engines) to the database'
  task :configs, [:config_load_path] => :environment do |_, args|
    args.with_defaults(:config_load_path => 'import_configs.yaml')

    import_data = YAML.load_file(Rails.root.join(args[:config_load_path]))

    Peatio::Import.new(import_data).load_all
  end

  desc 'Load local trades to the influx'
  task trade_to_influx: :environment do
    Trade.find_in_batches do |batch|
      batch.each_with_index do |trade, index|
        # We will convert created_at to ms and update it with index to make sure that we have unique
        # timestamps for each trade because influxdb use timestamp as unique identifier.
        influx_data = trade.influx_data.merge(timestamp: trade.created_at.to_i * 1000 + index)
        Peatio::InfluxDB.client(keyshard: trade.market_id).write_point('trades', influx_data, "ms")
      end
    end
  end

  desc 'Build candles for all trades in influx'
  task influx_build_candles: :environment do
    prev_from = 'trades'
    Peatio::InfluxDB.config[:host].each do |host|
      client = Peatio::InfluxDB.client(host: [host])
      client.query('SELECT FIRST(price) AS open, max(price) AS high, min(price) AS low, last(price) AS close, sum(amount) AS volume INTO candles_1m FROM trades GROUP BY time(1m), market')
      prev_from = 'candles_1m'
      KLineService::HUMANIZED_POINT_PERIODS.except(1).each do |_, v|
        client.query("SELECT FIRST(open) as open, MAX(high) as high, MIN(low) as low, LAST(close) as close, SUM(volume) as volume INTO candles_#{v} FROM #{prev_from} GROUP BY time(#{v}), market")
        prev_from = "candles_#{v}"
      end
    end
  end
end
