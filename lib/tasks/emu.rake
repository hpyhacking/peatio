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

  desc "Mock coin deposits."
  task deposits: :environment do
    m = Member.find_by_email ENV['email']
    a = m.get_account(ENV['account'])
    10.times do |i|
      timestamp = Time.now.to_i
      txid = "mock#{SecureRandom.hex(32)}"
      txout = 0
      address = a.payment_address.address
      amount = rand(100000)
      confirmations = 100
      receive_at = Time.now
      channel = DepositChannel.find_by_key a.currency_obj.key
      #pt_class = "PaymentTransaction::#{channel.currency.camelize}".constantize

      ActiveRecord::Base.transaction do
        tx = PaymentTransaction.create!(
          txid: txid,
          txout: txout,
          address: address,
          amount: amount,
          confirmations: confirmations,
          receive_at: receive_at,
          currency: channel.currency
        )

        deposit = channel.kls.create!(
          payment_transaction_id: tx.id,
          txid: tx.txid,
          txout: tx.txout,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          confirmations: tx.confirmations
        )

        deposit.submit!
        deposit.accept!
      end
    end
  end
end
