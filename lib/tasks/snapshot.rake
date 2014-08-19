namespace :snapshot do

  desc "snapshot of orderbook"
  task orderbook: :environment do
    asks = []
    OrderAsk.where(state: 'wait').group_by(&:member_id).each do |mid, orders|
      amount = orders.map(&:volume).reduce(&:+)
      m = Member.find mid
      asks << [m.id, m.email, amount]
    end

    bids = []
    OrderBid.where(state: 'wait').group_by(&:member_id).each do |mid, orders|
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
