namespace :order do
  task mock: :environment do
    m = Member.find_by_email 'crazyflapjack@gmail.com'
    market = Market.find 'btccny'

    low = 80 
    high = 500
    mid = 220
    (low..high).each do |price|
      klass = price < mid ?  OrderBid : OrderAsk
      volume = rand

      order = klass.new(
        source:        'APIv2',
        state:         ::Order::WAIT,
        member_id:     m.id,
        ask:           market.base_unit,
        bid:           market.quote_unit,
        currency:      market.id,
        ord_type:      'limit',
        price:         price,
        volume:        volume,
        origin_volume: volume
      )

      Ordering.new(order).submit
    end
  end
end
