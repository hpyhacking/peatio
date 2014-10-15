namespace :stats do

  def collect_stats(ts)
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

    member_stats = Worker::MemberStats.new.get_point(ts, 1440)

    { trade_users:  trade_users,
      top_stats:    top_stats,
      fund_stats:   fund_stats,
      wallet_stats: wallet_stats,
      member_stats: member_stats }
  end

  desc "send stats summary email"
  task email: :environment do
    yesterday = 1.day.ago(Time.now.beginning_of_day)
    base      = 1.day.ago(yesterday)

    yesterday_stats = collect_stats yesterday.to_i
    base_stats      = collect_stats base.to_i

    SystemMailer.daily_stats(yesterday.to_i, yesterday_stats, base_stats).deliver
  end

end
