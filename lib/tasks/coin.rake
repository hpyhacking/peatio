namespace :coin do
  desc "Sync coin deposit transactions"
  task sync_deposit: :environment do
    code    = ENV['code']
    account = 'payment'
    number  = 100
    channel = DepositChannel.find_by_currency(code)

    if channel.blank?
      puts "Can not find the deposit channel by code: #{code}"
      exit 0
    end

    CoinRPC[code].listtransactions(account, number).each do |tx|
      AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
    end
  end
end

