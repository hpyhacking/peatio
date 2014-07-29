namespace :maker do
  def history_in_time_range(m, t1, t2)
    scope  = Trade.with_currency('btccny').where(created_at: t1..t2)
    all_volume = scope.sum('volume')
    all_count  = scope.count

    scope  = Trade.with_currency('btccny').where(created_at: t1..t2).where('(ask_member_id = ? AND bid_member_id != ?) OR (ask_member_id != ? AND bid_member_id = ?)', m.id, m.id, m.id, m.id)
    maker_volume = scope.sum('volume')
    maker_count  = scope.count

    scope  = Trade.with_currency('btccny').where(created_at: t1..t2).where('bid_member_id != ? AND ask_member_id != ?', m.id, m.id)
    volume = scope.sum('volume')
    count  = scope.count

    puts "#{t1} %12s/%6d %12s/%6d %12s/%6d" % [volume.to_s('F'), count, maker_volume.to_s('F'), maker_count, all_volume.to_s('F'), all_count]
  end

  def api_orders_in_time_range(m, t1, t2)
    scope = Order.where(created_at: t1..t2, source: 'APIv2')
    count = scope.count
    maut10 = scope.group('member_id').select('*, count(*) as c').order('c desc').limit(10)
    maut10stats = maut10.map do |o|
      n = o.member.name.size == 2 ? 11 : 10
      "%-#{n}s%-30s%-10s" % [o.member.name, o.member.email, o.c]
    end
    maut10vol = maut10.map do |o|
      Trade.where(created_at: t1..t2).where('ask_member_id = ? OR bid_member_id = ?', o.member_id, o.member_id).sum(:volume) 
    end

    puts "\n"
    maut10stats.each_with_index do |s, i|
      if i == 0
        puts "%-30s%-15s%-40s%-10s" % [t1, count, s, maut10vol[i]]
      else
        puts "%-30s%-15s%-40s%-10s" % ['', '', s, maut10vol[i]]
      end
    end
  end

  def target_email
    Rails.env.production? ? 'forex@peatio.com' : 'foo@peatio.dev'
  end

  desc "generate real trade volume"
  task volume: :environment do
    daily = Member.find_by_email(target_email).trades.
      where('ask_member_id <> bid_member_id').
      group_by{|t| t.created_at.to_date}

    daily.each do |date, trades|
      puts "#{date.to_s}: #{trades.sum(&:volume).to_f.round(2)}"
    end
  end

  task last_seven_days_history: :environment do
    m = Member.find_by_email target_email
    Time.zone = 'Beijing'

    7.downto(0).each do |i|
      t1 = i.days.ago.beginning_of_day
      t2 = i.days.ago.end_of_day
      history_in_time_range m, t1, t2
    end
  end

  task last_seven_days_api_orders: :environment do
    m = Member.find_by_email target_email
    Time.zone = 'Beijing'

    puts "%-30s%-15s%-50s" % %w(Day Total MostActiveUserTop10)
    7.downto(0).each do |i|
      t1 = i.days.ago.beginning_of_day
      t2 = i.days.ago.end_of_day
      api_orders_in_time_range(m, t1, t2)
    end
  end
end
