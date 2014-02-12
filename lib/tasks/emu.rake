namespace :emu do
  def create_account(id)
    if Account.exists?(id)
      id
    else
      Account.create \
        id: id, email: "user#{id}@emu.com",
        pin: '1234', pin_confirmation: '1234'
      id
    end
  end

  def bid_order(id, price, volume)
    order(id, price, volume, 'bid')
  end

  def ask_order(id, price, volume)
    order(id, price, volume, 'ask')
  end

  def order(id, price, volume, type)
    Order.create \
      ask: 'btc', bid: 'cny',
      type: type, account: create_account(id),
      price: price, volume: volume, pin: '1234'
  end

  desc "emulate order set 1"
  task order_set_1: :environment do
    bid_order(1, "5.0", "5.0")
    ask_order(2, "5.0", "5.0")
  end

  desc "emulate many order"
  task order_many_set: :environment do
    (1..1000).each do 
      bid_order(1, "5.0", "5.0")
      ask_order(2, "5.0", "5.0")
      bid_order(2, "5.0", "5.0")
      ask_order(1, "5.0", "5.0")
    end
  end

  desc "emulate bid order"
  task bid: :environment do
    bid_order(1, "10", "2.0")
  end

  desc "emulate ask order"
  task ask: :environment do
    i = (10..20).to_a.sample
    p = (1..8).to_a.sample
    ask_order(2, "#{i}.#{p}", "2.0")
  end


  desc "emulate order set 2"
  task order_set_2: :environment do
    # strike volume == 2.0
    # strike price == 5.3
    bid_order(1, "5.5", "5.0")
    ask_order(2, "5.3", "2.0")
  end
end
