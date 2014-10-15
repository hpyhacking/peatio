namespace :stats do

  desc "send stats summary email"
  task email: :environment do
    yesterday = 1.day.ago.beginning_of_day
    ts = yesterday.to_i

    trade_users = {}
    top_stats = {}
    Market.all.each do |market|
      trade_users[market.id] = Worker::TradeStats.new(market).get_point(ts, 1440)
      top_stats[market.id] = Worker::TopStats.new(market).get_point(ts, 1440)
    end

    fund_stats = {}
    wallet_stats = {}
    Currency.all.each do |currency|
      fund_stats[currency.code] = Worker::FundStats.new(currency).get_point(ts, 1440)
      wallet_stats[currency.code] = Worker::WalletStats.new(currency).get_point(ts, 1440)
    end
  end

end
