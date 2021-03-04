# frozen_string_literal: true

namespace :job do
  namespace :order do
    desc 'Close orders older than ORDER_MAX_AGE.'
    task close: :environment do
      Job.execute('close_orders') do
        order_max_age = ENV.fetch('ORDER_MAX_AGE', 2_419_200).to_i

        # Cancel orders that older than max_order_age
        orders = Order.where('created_at < ? AND state = ?', Time.now - order_max_age, 100)
        orders.each do |o|
          Order.cancel(o.id)
        end

        { pointer: Time.now.to_s(:db), counter: orders.count }
      end
    end

    desc 'Archive and delete old cancelled orders without trades to the archive database.'
    task archive: :environment do
      Job.execute('archive_orders') do
        time = Time.now
        # default batch 1000
        count = Order.where(state: :cancel, trades_count: 0).where('updated_at < ?', time - 1.week).count
        Order.where(state: :cancel, trades_count: 0).where('updated_at < ?', time - 1.week).find_in_batches do |batch|
          ActiveRecord::Base.establish_connection(:archive_db)
          batch.each do |o|
            Order.new(o.attributes).save!(validate: false)
          end
          ActiveRecord::Base.establish_connection
          batch.each do |o|
            o.delete
          end
        end
        { pointer: time, counter: count }
      end
    end

    desc 'Delete old cancelled orders without trades to the archive database.'
    task delete: :environment do
      Job.execute('delete_orders') do
        count = 0
        time = Time.now
        exist = true
        while exist
          batch = Order.where(state: :cancel, trades_count: 0).where('updated_at < ?', time - 1.week).limit(1000).delete_all
          count += batch
          exist = false if batch.zero?
        end
        { pointer: time, counter: count }
      end
    end

    def order_insert
      'INSERT INTO orders (id, uuid, remote_id, bid, ask, market_id, price, ' \
      'volume, origin_volume, maker_fee, taker_fee, state, type, member_id, ord_type, ' \
      'locked, origin_locked, funds_received, trades_count, created_at, updated_at) VALUES ' \
    end

    def order_values(order)
      order['remote_id'] = order['remote_id'].nil? ? 'NULL' : order['remote_id']
      order['uuid'] = UUID::Type.new.quoted_id(order['uuid'])
      "(#{order['id']}, #{order['uuid']}, #{order['remote_id']}, " \
      "'#{order['bid']}', '#{order['ask']}', '#{order['market_id']}', " \
      "#{order['price']}, #{order['volume']}, #{order['origin_volume']}, " \
      "#{order['maker_fee']}, #{order['taker_fee']}, #{order['state']}, " \
      "'#{order['type']}', #{order['member_id']}, '#{order['ord_type']}', " \
      "#{order['locked']}, #{order['origin_locked']}, #{order['funds_received']}, " \
      "#{order['trades_count']}, '#{order['created_at']}', '#{order['updated_at']}')"
    end
  end

  namespace :liabilities do
    desc 'Compact liabilities using Stored Procedure'
    task :compact_orders, %i[min_time max_time] => [:environment] do |_, args|
      Job.execute('compact_orders') do
        # Connection to the main database
        main_db = if Rails.configuration.database_adapter.downcase == 'PostgreSQL'.downcase
                    ActiveRecord::Base.connection.raw_connection
                  else
                    Mysql2::Client.new(sql_config(ENV.fetch('RAILS_ENV', 'development')))
                  end
        # Execute Stored Procedure for Liabilities compacting
        # Example:
        # Current date: "2020-07-30 16:39:15"
        # min_time: "2020-07-23 00:00:00"
        # max_time: "2020-07-24 00:00:00"
        # Compact liabilities beetwen: "2020-07-23 00:00:00" and "2020-07-24 00:00:00"
        args.with_defaults(min_time: (Time.now - 1.week).beginning_of_day.to_s(:db),
                           max_time: (Time.now - 6.day).beginning_of_day.to_s(:db))
        result = if Rails.configuration.database_adapter.downcase == 'PostgreSQL'.downcase
                   main_db.query("select * from compact_orders('#{args.min_time}'::date, '#{args.max_time}'::date);")
                 else
                   main_db.query("call compact_orders('#{args.min_time}', '#{args.max_time}');")
                 end
        result.first
      end
    end
  end

  def sql_config(namespace)
    yaml = ::Pathname.new('config/database.yml')
    return {} unless yaml.exist?

    ::SafeYAML.load(::ERB.new(yaml.read).result)[namespace]
  end
end
