require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

@running = true

Signal.trap('TERM') do
  @running = false
end

@coins = Currency.where(coin: true)
@coins.reject! { |coin| DepositChannel.find_by_currency(coin.code).blank? }

while @running
  @coins.each do |coin|
    account = 'payment'
    number  = 100
    channel = DepositChannel.find_by_currency(coin.code)
    missed  = []

    if channel.blank?
      puts "Can not find the deposit channel by code: #{code}"
      next
    end

    CoinRPC[coin.code.to_sym].listtransactions(account, number).each do |tx|
      next if tx['category'] != 'receive'

      unless PaymentTransaction::Normal.find_by(txid: tx['txid'])
        puts "#{coin.code} --- Missed txid:#{tx['txid']} address:#{tx['address']} (#{tx['amount']})"
        missed << tx
      end
    end

    puts "#{coin.code} --- #{missed.size} missed transactions found."

    next if missed.empty?

    puts "#{coin.code} --- Reprocessing .."
    missed.each do |tx|
      AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
    end
    puts "#{coin.code} --- Done."
  end

  sleep 5
end
