namespace :snapshot do

  desc "calculate member active order voulme percentage of ME snapshot"
  task member_volume: :environment do
    ask_orders = Hash.new{|h,k| h[k] = 0}
    bid_orders = Hash.new{|h,k| h[k] = 0}
    File.readlines('/tmp/limit_orderbook_btccny').each do |line|
      line.strip!
      current = nil
      case line.strip
      when /(\d+)\/\$([0-9.]+)\/([0-9.]+)/
        order = Order.find $1
        volume = BigDecimal.new $3
        if order.is_a?(OrderAsk)
          ask_orders[order.member_id] += volume
        else
          bid_orders[order.member_id] += volume*order.price
        end
      else
        puts "skip line: #{line}"
      end
    end

    asks = ask_orders.map do |mid, amount|
      m = Member.find mid
      [m.id, m.email, m.accounts.with_currency(:btc).first.payment_address.address, amount]
    end
    bids = bid_orders.map do |mid, amount|
      m = Member.find mid
      [m.id, m.email, m.accounts.with_currency(:btc).first.payment_address.address, amount]
    end

    asks_total = asks.map(&:last).reduce(&:+)
    bids_total = bids.map(&:last).reduce(&:+)

    asks.each{|ask| ask << (ask.last / asks_total).round(8) }
    bids.each{|bid| bid << (bid.last / bids_total).round(8) }

    IO.write Rails.root.to_s + '/asks.csv', asks.collect{|item| item.join(',')}.join("\n")
    IO.write Rails.root.to_s + '/bids.csv', bids.collect{|item| item.join(',')}.join("\n")
  end

  desc "snapshot of orderbook"
  task orderbook: :environment do
    asks = []
    OrderAsk.active.with_currency('btccny').group_by(&:member_id).each do |mid, orders|
      amount = orders.map(&:volume).reduce(&:+)
      m = Member.find mid
      asks << [m.id, m.email, amount]
    end

    bids = []
    OrderBid.active.with_currency('btccny').group_by(&:member_id).each do |mid, orders|
      amount = orders.collect{|order| order.volume * order.price }.reduce(&:+)
      m = Member.find mid
      bids << [m.id, m.email, amount]
    end

    asks_total = asks.map(&:last).reduce(&:+)
    bids_total = bids.map(&:last).reduce(&:+)

    asks.each{|ask| ask << (ask.last / asks_total).round(8) }
    bids.each{|bid| bid << (bid.last / bids_total).round(8) }

    IO.write Rails.root.to_s + '/asks.csv', asks.collect{|item| item.join(',')}.join("\n")
    IO.write Rails.root.to_s + '/bids.csv', bids.collect{|item| item.join(',')}.join("\n")
  end

end
